# Especificación Técnica — Reimplementación de la app de Órdenes de Trabajo (Viajes) y cálculo de gasoil

> **Versión:** 1.0  
> **Fecha:** 2026-07-20  
> **Proyecto:** GAS-APP (SAP CAP / Node.js / UI5 Fiori Elements)  
> **Ámbito:** Reemplazo de la app `viajes-maint` y refactorización del cálculo de combustible asociado a viajes, surtidos y telemetría.

---

## 1. Objetivos

1. Reimplementar la aplicación **“Orden de trabajo”** (`viajes-maint`) como una app Fiori Elements robusta, clara en unidades y trazable en el cálculo de gasoil.
2. Corregir el modelo de cálculo del **rendimiento teórico** y el **consumo real**.
3. Integrar **telemetría**, **surtidos** y **órdenes de carga** en un solo flujo de datos coherente.
4. Establecer una base de tests automatizados para los cálculos de combustible.
5. Facilitar la evolución futura: coeficientes versionados, precios históricos, reporting y alertas.

---

## 2. Alcance

### Dentro del alcance

- Entidad `Viaje` y su servicio OData (`ConfigService.Viajes`).
- Entidad `SurtidoUnidad` y su relación con `Viaje`.
- Entidad `Telemetria` y su función en el cálculo de consumo real.
- Entidad `Vehiculo` (niveles de combustible, capacidad, rendimiento base).
- Entidad `Tanque` e `OrdenCarga` (solo en lo que afecta el surtido y el inventario).
- Utilidad `rendimientoCalculator` y su modelo de regresión.
- Aplicación Fiori `app/viajes-maint` (List Report + Object Page + extensiones).
- Vistas de reporting del Overview Page y `ReportingService` que dependen de los campos de consumo.

### Fuera del alcance (para esta fase)

- Reemplazo completo de la arquitectura de CAP por otro framework.
- Implementación de autenticación/autorización (se mantiene el modelo actual de servicio abierto).
- Rediseño de módulos ajenos a viajes/combustible (caja, choferes, almacenes, etc.) salvo los cambios mínimos requeridos para la integración.
- Integración con hardware de telemetría (sólo se consume la entidad existente).

---

## 3. Arquitectura objetivo

```text
┌─────────────────────────────────────────────────────────────┐
│                    UI5 Fiori Elements                       │
│                  app/viajes-maint (nueva)                   │
└──────────────────────┬──────────────────────────────────────┘
                       │ OData V4
┌──────────────────────▼──────────────────────────────────────┐
│                     ConfigService                           │
│  Viajes  │  SurtidosUnidad  │  Telemetrias  │  Vehiculos   │
│  Tanques │  OrdenesCarga    │  Proveedores  │  Rutas       │
└──────────────────────┬──────────────────────────────────────┘
                       │ Handlers + servicios auxiliares
┌──────────────────────▼──────────────────────────────────────┐
│         Capa de negocio (srv/<módulo>/service/*.js)         │
│   • viaje-service.js        (creación, cálculo teórico)     │
│   • telemetria-service.js   (consumo real)                  │
│   • surtido-unidad-service.js (inventario y vinculación)    │
│   • rendimientoCalculator.js (modelo parametrizable)        │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                     PostgreSQL 16                           │
└─────────────────────────────────────────────────────────────┘
```

Principios arquitectónicos:

- **Unidades explícitas:** cada campo numérico debe indicar su unidad (en el nombre, en la anotación `@Measures.Unit` y en documentación).
- **Lógica centralizada en el backend:** el frontend no calcula consumo ni rendimiento; solo presenta y dispara acciones.
- **Cálculo idempotente:** los valores derivados se recalculan siempre a partir de los datos fuente (telemetría, surtidos, parámetros del vehículo/ruta).
- **Trazabilidad:** cada cambio en inventario o en consumo debe poder auditarse.

---

## 4. Modelo de datos (cambios propuestos)

### 4.1 Entidad `Viaje`

Ubicación: `db/Viaje/viaje-schema.cds`

Campos a **mantener** (con posible renombre para claridad):

| Campo | Tipo | Unidad | Descripción |
|-------|------|--------|-------------|
| `ID` | UUID | - | Clave primaria |
| `vehiculo` | Association → Vehiculo | - | Vehículo asignado |
| `chofer` | Association → Chofer | - | Chofer asignado |
| `ruta` | Association → Ruta | - | Ruta planificada |
| `fecha` | Date | - | Fecha del viaje |
| `horaSalida` | DateTime | - | Hora de salida estimada |
| `horaLlegada` | DateTime | - | Hora de llegada estimada |
| `horaLlegadaReal` | DateTime | - | Hora de llegada real |
| `estatus` | String / Association | - | Programado, EnCurso, Finalizado, Cancelado |
| `proveedor` | Association → Proveedor | - | Proveedor de combustible asignado |
| `pesoIda` | Decimal(10,2) | kg | Peso de carga de ida |
| `pesoVuelta` | Decimal(10,2) | kg | Peso de carga de vuelta |
| `numeroViaje` | Integer64 | - | Número secuencial |
| `numeroViajeFormateado` | String | - | Número con formato `00001` |

Campos a **modificar o renombrar**:

| Campo actual | Cambio propuesto | Motivo |
|--------------|------------------|--------|
| `kilometrosRecorridos` | `kilometrosRecorridos` (mantener) | Distancia real calculada por telemetría. Unidad: km. |
| `litrosSalida` | `combustibleInicial` | Nivel de combustible al inicio del viaje. Unidad: L. |
| `pesoCarga` | `pesoTotal` o eliminar | Hoy no se usa; se recomienda usar `pesoIda + pesoVuelta`. |
| `consumoRealTotal` | `consumoRealTotal` (mantener) | Litros consumidos netos. Unidad: L. |
| `consumoTeoricoTotal` | `consumoTeoricoTotal` | Poblarlo con `distanciaPlanificada / rendimientoTeorico`. Unidad: L. |
| `kilometrosPorLitro` | `rendimientoRealKmPorLitro` | `kilometrosRecorridos / consumoRealTotal`. Unidad: km/L. |
| `horasPorLitro` | `horasPorLitro` (mantener) | Consumo a baja velocidad. Unidad: h/L. |
| `rendimientoTeorico` | `rendimientoTeoricoKmPorLitro` | km/L. |
| `combustibleTeorico` | `combustibleTeoricoLitros` | L. |
| `costoTeorico` | `costoTeoricoUSD` | USD. |
| Nuevo: `costoRealUSD` | Decimal(12,2) | USD | `consumoRealTotal × precioCombustibleReal`. |
| Nuevo: `desviacionConsumoLitros` | Decimal(10,2) | L | `consumoRealTotal - combustibleTeoricoLitros`. |
| Nuevo: `desviacionPorcentaje` | Decimal(5,2) | % | Desviación porcentual vs. teórico. |

Campos a **eliminar o deprecar**:

- `origen`, `latitudOrigen`, `longitudOrigen`, `destino`, `latitudDestino`, `longitudDestino` (se toman de `Ruta`, evitar duplicación).
- `minHoraSalida` (no se usa en la lógica actual).

### 4.2 Entidad `SurtidoUnidad`

Ubicación: `db/SurtidoUnidad/surtido-unidad-schema.cds`

| Cambio | Descripción |
|--------|-------------|
| Nuevo campo `viaje_ID` (UUID, opcional) | Permite vincular un surtido a un viaje específico. |
| Nuevo campo `esInicial` (Boolean) | `true` si el surtido se realiza al inicio del viaje; `false` si es durante el viaje. |
| Nuevo campo `kilometrajeSurtido` (Decimal(10,2), km) | Kilometraje del vehículo en el momento del surtido (para auditoría). |
| Renombrar `carga_real` → `litrosCargados` | Claridad. Unidad: L. |
| Mantener `volumenPrevioVehiculo` y `volumen_actual_vehiculo` | Unidad: L. |

### 4.3 Entidad `Telemetria`

Ubicación: `db/Telemetria/telemetria-schema.cds`

Sin cambios estructurales, pero se recomienda agregar:

| Campo nuevo | Tipo | Descripción |
|-------------|------|-------------|
| `odometro` | Decimal(10,2) | Kilometraje acumulado del vehículo para validar distancias. |
| `calidadDato` | String | `OK`, `ANOMALO`, `INTERPOLADO`. |

### 4.4 Entidad `Vehiculo`

Ubicación: `db/Vehiculo/vehiculo-schema.cds`

Campos a mantener:

- `nivelActualCombustible` (L)
- `capacidadTotal` (L) — calculada de los tanques del vehículo.
- `rendimientoBase` (km/L) — referencia nominal.
- `tipo_combustible` — para validación con tanque y almacén.

### 4.5 Nueva entidad `ConfiguracionRendimiento`

Ubicación propuesta: `db/ConfiguracionRendimiento/configuracion-rendimiento-schema.cds`

```cds
entity ConfiguracionRendimiento : cuid, managed {
  version              : String;          // Ej. "2026.1"
  fechaCalibracion     : Date;
  unidadSalida         : String default 'L/1000km'; // L/1000km
  notas                : String;
  coeficientes         : Composition of many ConfiguracionRendimientoCoef;
  activo               : Boolean default false;
}

entity ConfiguracionRendimientoCoef : cuid {
  config       : Association to ConfiguracionRendimiento;
  nombre       : String; // Beta0, c1, c2, c3, c4, c5
  valor        : Double;
  descripcion  : String;
}
```

Objetivo: evitar coeficientes hardcodeados y permitir versionado del modelo.

### 4.6 Nueva entidad `PrecioCombustible` (histórico por proveedor)

Si no existe, se reemplaza/amplía `PreciosHistoricos` para soportar vigencia:

```cds
entity PrecioCombustible : cuid, managed {
  proveedor    : Association to Proveedor;
  fechaDesde   : Date;
  fechaHasta   : Date;
  precio       : Decimal(10,4); // USD/L
  moneda       : String default 'USD';
}
```

El handler de costo teórico debe usar el precio vigente a la fecha del viaje.

---

## 5. Servicios OData

### 5.1 `ConfigService`

Extender en `srv/Viaje/service/viaje-service.cds`:

```cds
extend service ConfigService with {
  @odata.draft.enabled
  entity Viajes as projection on DbViaje { ... } actions {
    action iniciarViaje();
    action finalizarViaje();
    action changeStatus();
  };

  entity SurtidosUnidad as projection on DbSurtidoUnidad;
  entity Telemetrias as projection on DbTelemetria;
  entity ConfiguracionesRendimiento as projection on DbConfiguracionRendimiento;
  entity PreciosCombustible as projection on DbPrecioCombustible;
}
```

### 5.2 `ReportingService` / `OverviewPage`

Actualizar las vistas para usar los nuevos campos:

- `rendimientoPromedioReal` → `avg(rendimientoRealKmPorLitro)`
- `consumoTotal` → `sum(consumoRealTotal)`
- `costoTotal` → `sum(costoRealUSD)`
- `desviacionPromedio` → `avg(desviacionPorcentaje)`

---

## 6. Lógica de negocio detallada

### 6.1 Creación de un viaje (nuevo flujo)

1. **Usuario presiona “Crear”** en el List Report.
2. **Backend `before NEW` en `Viajes.drafts`:**
   - Asignar `numeroViaje` = `max(numeroViaje) + 1`.
   - Inicializar campos calculados a `0` o `null`.
   - Copiar `vehiculo.tipo_combustible` a un campo no editable para validación.
3. **Usuario completa datos en el Object Page:**
   - Selecciona vehículo, chofer, ruta, proveedor, pesos, fecha.
4. **Backend `before UPDATE` en `Viajes.drafts`:**
   - Validar transiciones de estado.
   - Calcular rendimiento teórico, combustible teórico y costo teórico.
   - Guardar valores en los campos correspondientes.
5. **Usuario activa el borrador (save/activate).**
6. **Backend durante activación:**
   - Re-ejecutar el cálculo teórico con los datos finales.
   - Registrar `combustibleInicial = vehiculo.nivelActualCombustible`.
   - Si no hay combustible suficiente para el teórico, advertir (no bloquear, salvo política estricta).
7. **Usuario inicia el viaje** (acción `iniciarViaje`):
   - Validar estado `Programado` → `EnCurso`.
   - Opcional: crear un `SurtidoUnidad` inicial vinculado al viaje si el vehículo se carga.

### 6.2 Cálculo del rendimiento teórico (refactorizado)

Ubicación: `srv/utils/rendimientoCalculator.js` o servicio con entidad `ConfiguracionRendimiento`.

```js
function calcularRendimiento(params, coeficientes) {
  const {
    peso_por_eje,        // kg/eje
    un_tramo_bool,       // true = ida sin vuelta
    ln_km,               // ln(distanciaKm)
    tres_ejes_bool,      // true = 3 ejes
    relacion_transmision,
    coeficiente_motor
  } = params;

  const un_tramo = un_tramo_bool ? 1 : 0;
  const tres_ejes = tres_ejes_bool ? 1 : 0;

  const consumoL/1000km =
      coeficientes.Beta0
    + coeficientes.c1 * peso_por_eje
    + coeficientes.c2 * un_tramo
    + coeficientes.c3 * ln_km
    + coeficientes.c4 * tres_ejes
    + coeficientes.c5 * relacion_transmision
    + coeficiente_motor;

  if (consumoL/1000km <= 0) return null; // Error de modelo

  // Convertir a km/L para presentación uniforme
  const rendimientoKmPorLitro = 1000 / consumoL/1000km;
  return rendimientoKmPorLitro;
}
```

Validaciones:

- `distanciaKm > 0`.
- `peso_por_eje > 0`.
- `relacion_transmision > 0`.
- Resultado dentro de un rango realista (ej. 1–10 km/L). Si está fuera, advertir y registrar.

### 6.3 Cálculo del consumo real (refactorizado)

Ubicación: `srv/Telemetria/service/telemetria-service.js`.

Fórmula propuesta:

```text
consumoRealTotal = combustibleInicial
                 + suma(litrosCargados de surtidos vinculados al viaje)
                 - nivelCombustibleFinal
```

Procedimiento `recalcularViaje(viajeId)`:

1. Obtener `combustibleInicial` del viaje.
2. Obtener surtidos vinculados (`viaje_ID = viajeId`), ordenados por fecha.
3. Obtener telemetrías ordenadas por timestamp, filtrando anómalos.
4. Calcular:
   - `nivelCombustibleFinal` = última telemetría válida.
   - `sumaSurtidos` = suma de `litrosCargados`.
   - `consumoRealTotal = combustibleInicial + sumaSurtidos - nivelCombustibleFinal`.
   - `kilometrosRecorridos` = suma Haversine entre puntos con velocidad > 5 km/h.
5. Calcular derivados:
   - `rendimientoRealKmPorLitro = kilometrosRecorridos / consumoRealTotal`.
   - `horasPorLitro` = horas a velocidad < 5 km/h / consumoRealTotal.
   - `costoRealUSD = consumoRealTotal × precioCombustibleVigente`.
6. Calcular desviaciones vs. teórico:
   - `desviacionConsumoLitros = consumoRealTotal - combustibleTeoricoLitros`.
   - `desviacionPorcentaje = (desviacionConsumoLitros / combustibleTeoricoLitros) × 100`.
7. Persistir todos los valores en `Viaje`.

Manejo de repostajes:

- Si el nivel de combustible sube entre dos telemetrías sin un surtido registrado, marcar las telemetrías como anómalas o generar una advertencia.
- Si hay un surtido registrado, el cálculo neto lo compensa correctamente.

### 6.4 Surtido de unidad (refactorizado)

Ubicación: `srv/SurtidoUnidad/service/surtido-unidad-service.js`.

Cambios:

- Al crear un surtido, permitir seleccionar un viaje activo (`EnCurso`) del vehículo.
- Si se selecciona viaje, establecer `viaje_ID` y `esInicial` según corresponda.
- Actualizar `Vehiculo.nivelActualCombustible` y `Tanque.nivel_actual` como hoy.
- Disparar `recalcularViaje(viajeId)` si se vinculó un viaje.

### 6.5 Orden de Carga

Sin cambios estructurales. Se mantiene la lógica actual de `isFirst` y descuento de tanques. Se recomienda:

- Calcular `precio`, `variacion` y `porcentaje_conciliacion` también en `CREATE` (no solo en `UPDATE`).
- Usar `PrecioCombustible` vigente en lugar de `PreciosHistoricos` sin rango de vigencia.

---

## 7. Frontend (app `viajes-maint`)

### 7.1 Estructura propuesta

```
app/viajes-maint/
├── webapp/
│   ├── manifest.json              (LROP V4, draft enabled)
│   ├── Component.js
│   ├── i18n/i18n.properties
│   └── ext/
│       ├── controller/
│       │   └── ViajeObjectPage.controller.js
│       ├── fragment/
│       │   ├── HeaderTitle.fragment.xml
│       │   ├── ChoferHeader.fragment.xml
│       │   ├── MapaRuta.fragment.xml
│       │   ├── ConsumoPromedioMicroChart.fragment.xml
│       │   └── HeaderCharts.fragment.xml
│       ├── view/
│       │   └── MapaRutaView.view.xml
│       └── util/
│           └── GoogleMaps.js
```

### 7.2 Páginas

- **List Report Page:**
  - Filtros por fecha, estado, vehículo, chofer, ruta.
  - Columnas: número de viaje, fecha, ruta, vehículo, estado, consumo real, consumo teórico, desviación %.
  - Botón “Crear” que abre Object Page en modo edición.
- **Object Page:**
  - Secciones: Datos generales, Vehículo/Chofer, Ruta, Combustible, Telemetría, Surtidos, Mapa.
  - Campos de combustible con `@readonly` y `@Measures.Unit`.
  - Acciones: `iniciarViaje`, `finalizarViaje`, `changeStatus`.
  - Microchart de comparación consumo real vs. teórico.

### 7.3 Extensiones necesarias

- `ViajeObjectPage.controller.js`:
  - Sincronizar título con ruta y número de viaje.
  - Manejar visibilidad de acciones según estado.
  - Refrescar sección de combustible tras cambios de estado.
- Fragmentos:
  - `Combustible.fragment.xml`: mostrar rendimiento teórico, real, consumo real, consumo teórico, desviación y costos.
  - `MapaRuta.fragment.xml`: mostrar ruta y puntos de telemetría.

### 7.4 Anotaciones CDS (UI)

Ubicación: `srv/Viaje/annotations/annotationsViajes2.cds` y `srv/Viaje/annotations/annotationsViaje.cds` (nuevo).

Ejemplo de anotaciones a agregar:

```cds
annotate ConfigService.Viajes with {
  rendimientoTeoricoKmPorLitro @title: 'Rendimiento teórico' @Measures.Unit: 'km/L' @readonly;
  combustibleTeoricoLitros   @title: 'Combustible teórico' @Measures.Unit: 'L' @readonly;
  costoTeoricoUSD            @title: 'Costo teórico' @Measures.Unit: 'USD' @readonly;
  consumoRealTotal           @title: 'Consumo real' @Measures.Unit: 'L' @readonly;
  rendimientoRealKmPorLitro  @title: 'Rendimiento real' @Measures.Unit: 'km/L' @readonly;
  costoRealUSD               @title: 'Costo real' @Measures.Unit: 'USD' @readonly;
  desviacionPorcentaje       @title: 'Desviación vs. teórico' @Measures.Unit: '%' @readonly;
};
```

---

## 8. API OData (contrato)

### 8.1 Entidad `Viajes`

```http
GET /odata/v4/config/Viajes
GET /odata/v4/config/Viajes(ID=...)
POST /odata/v4/config/Viajes
PATCH /odata/v4/config/Viajes(ID=...)
POST /odata/v4/config/Viajes(ID=...)/ConfigService.iniciarViaje
POST /odata/v4/config/Viajes(ID=...)/ConfigService.finalizarViaje
POST /odata/v4/config/Viajes(ID=...)/ConfigService.changeStatus
```

Campos calculados devueltos siempre actualizados.

### 8.2 Entidad `SurtidosUnidad`

```http
POST /odata/v4/config/SurtidosUnidad
PATCH /odata/v4/config/SurtidosUnidad(ID=...)
```

Body de ejemplo:

```json
{
  "vehiculo_ID": "...",
  "tanque_ID": "...",
  "litrosCargados": 150,
  "viaje_ID": "...",
  "esInicial": false,
  "kilometrajeSurtido": 1250.5
}
```

### 8.3 Entidad `Telemetrias`

```http
POST /odata/v4/config/Telemetrias
```

Al crear/actualizar/eliminar se dispara el recálculo del viaje asociado.

---

## 9. Reglas de validación y mensajes de error

| Regla | Mensaje | Dónde |
|-------|---------|-------|
| Vehículo obligatorio | “Debe seleccionar un vehículo” | `before CREATE/UPDATE` |
| Ruta obligatoria | “Debe seleccionar una ruta” | `before CREATE/UPDATE` |
| Fecha obligatoria | “Debe indicar la fecha del viaje” | `before CREATE/UPDATE` |
| Distancia ruta > 0 | “La ruta no tiene una distancia válida” | `before UPDATE` |
| Transición de estado inválida | “Transición de estado inválida: X → Y” | `before UPDATE` / acciones |
| Consumo real negativo | “El consumo real calculado es negativo; revise telemetrías y surtidos” | `after recalcularViaje` |
| Desviación > 30% | “El consumo real supera el teórico en más de un 30%” | `after recalcularViaje` (advertencia) |
| Surtido excede capacidad vehículo | “La carga supera la capacidad del vehículo” | `before CREATE/UPDATE SurtidosUnidad` |
| Surtido sin tanque ni carga externa | “Debe indicar el tanque o marcar carga externa” | `before CREATE/UPDATE SurtidosUnidad` |

---

## 10. Seguridad y autorización

Para esta fase se mantiene el modelo actual: servicio abierto sin autenticación. Sin embargo, se recomienda documentar los puntos donde más adelante se aplicarán roles:

- Operadores de flota: crear/editar viajes y ver consumos.
- Supervisores: aprobar cambios de estado y ver costos.
- Administradores: editar configuración de rendimiento y precios.

---

## 11. Testing y calidad

### 11.1 Tests unitarios

Ubicación propuesta: `test/viaje-service.test.js` y `test/rendimientoCalculator.test.js`.

Casos mínimos:

- `calcularRendimiento` con valores de entrada conocidos produce resultado esperado.
- `recalcularViaje` con telemetrías lineales produce consumo real correcto.
- `recalcularViaje` con un surtido intermedio produce consumo neto correcto.
- Transición de estado inválida devuelve 400.
- Surtido que excede capacidad devuelve 400.
- Creación de viaje asigna número consecutivo.

### 11.2 Tests de integración

- Crear un viaje completo (draft → activo), cargar surtido inicial, cargar telemetrías, finalizar viaje, verificar que `consumoRealTotal`, `rendimientoRealKmPorLitro` y `costoRealUSD` son correctos.

### 11.3 Lint y formato

- Ejecutar `npx eslint .` antes de integrar.
- Todos los archivos nuevos deben seguir las convenciones del proyecto (ESLint + CDS).

---

## 12. Migración de datos

### 12.1 Consideraciones

- Los campos renombrados (`litrosSalida` → `combustibleInicial`) requieren un script de migración SQL o un handler de arranque.
- Los nuevos campos (`costoRealUSD`, `desviacionConsumoLitros`, etc.) pueden inicializarse en `0`.
- Los datos históricos de `consumoRealTotal` calculados por `max - min` de telemetría pueden quedar inconsistentes con la nueva fórmula. Se recomienda:
  - Recalcular todos los viajes finalizados con la nueva lógica.
  - Guardar un backup de los valores anteriores por si es necesario auditoría.

### 12.2 Script de migración sugerido

```bash
# 1. Backup de tabla Viaje
# 2. Ejecutar script SQL de renombrado y adición de columnas
# 3. Ejecutar node scripts/recalcular-consumo-historico.js
# 4. Verificar totales y desviaciones
```

---

## 13. Criterios de aceptación

1. Un usuario puede crear un viaje en el Fiori Launchpad, completar datos y ver el cálculo teórico de combustible y costo inmediatamente.
2. Al iniciar un viaje, se registra el nivel de combustible inicial del vehículo.
3. Al cargar telemetrías y/o surtidos vinculados al viaje, el sistema recalcula automáticamente el consumo real, el rendimiento real y el costo real.
4. El consumo real es correcto incluso si hay repostajes durante el viaje.
5. La app muestra la desviación entre consumo real y teórico.
6. Los coeficientes del modelo de rendimiento son versionables desde una entidad de configuración.
7. Los tests unitarios e integración pasan y el lint no reporta errores.
8. Las vistas de reporting y el Overview Page muestran datos consistentes con los nuevos campos.

---

## 14. Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Pérdida de datos históricos al renombrar columnas | Media | Alto | Backup previo y script de migración reversible. |
| Inconsistencia en consumo real por telemetría de baja calidad | Alta | Alto | Marcado de anomalías y validaciones de rangos. |
| Resistencia al cambio de unidades | Media | Medio | Documentación clara y anotaciones `@Measures.Unit` en CDS. |
| Dependencia de datos de surtidos que antes no se vinculaban a viaje | Media | Medio | Permitir surtidos sin viaje, pero incentivar la vinculación. |
| Cambios en el modelo de regresión afectan reportes | Baja | Medio | Versionado de coeficientes y recálculo masivo controlado. |

---

## 15. Dependencias y tareas previas

1. Definir con el negocio si se prioriza corregir datos históricos o solo viajes nuevos.
2. Confirmar si el modelo de regresión actual debe reemplazarse o sólo parametrizarse.
3. Confirmar la unidad oficial de los coeficientes (L/1000km).
4. Disponer de un ambiente PostgreSQL de prueba para validar la migración.

---

## 16. Referencias

- Informe de análisis previo: `informe_gasoil_orden_trabajo.md`
- Modelo actual: `db/Viaje/viaje-schema.cds`, `db/SurtidoUnidad/surtido-unidad-schema.cds`, `db/Telemetria/telemetria-schema.cds`
- Handlers actuales: `srv/Viaje/service/viaje-service.js`, `srv/Telemetria/service/telemetria-service.js`, `srv/SurtidoUnidad/service/surtido-unidad-service.js`
- Utilidad: `srv/utils/rendimientoCalculator.js`
- App actual: `app/viajes-maint/webapp/manifest.json`

---

*Fin de la especificación técnica.*
