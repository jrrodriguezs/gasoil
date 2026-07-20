# Informe: Cálculo del uso de gasoil en la creación de órdenes de trabajo (Viajes)

> Fecha del análisis: 2026-07-20  
> Aplicación revisada: `app/viajes-maint` (en el launchpad local figura como **“Orden de trabajo”**).  
> También se revisaron las entidades relacionadas: `OrdenCarga`, `SurtidoUnidad`, `Tanque`, `Telemetria`, `Vehiculo`.

---

## 1. Resumen ejecutivo

La funcionalidad de **“orden de trabajo”** en GAS-APP está implementada por la aplicación Fiori Elements **`viajes-maint`**, que expone la entidad `Viajes` del servicio OData `ConfigService` (`/odata/v4/config/Viajes`).

Durante la creación/edición de un viaje, el backend ejecuta dos grandes procesos relacionados con el combustible:

1. **Cálculo teórico** del rendimiento y del combustible/costo estimado (`srv/Viaje/service/viaje-service.js`).
2. **Cálculo real** del consumo, que se dispara posteriormente desde los registros de telemetría del vehículo (`srv/Telemetria/service/telemetria-service.js`).

El flujo no está integrado de forma transaccional con los **surtidos de combustible** (`SurtidoUnidad`) ni con las **órdenes de carga** (`OrdenCarga`). Esto genera inconsistencias potenciales en el cálculo del consumo real, especialmente cuando un vehículo se reposta durante un viaje.

---

## 2. Aplicación y puntos de extensión

| Elemento | Ruta | Observación |
|----------|------|-------------|
| App Fiori | `app/viajes-maint/webapp/manifest.json` | List Report / Object Page sobre `ConfigService.Viajes`. Drafts habilitados. |
| Launchpad | `app/index.html:39` | Tile etiquetado **“Orden de trabajo”** apunta a `#Viajes-manage`. |
| Extensión OP | `app/viajes-maint/webapp/ext/controller/ViajeObjectPage.controller.js` | Sólo maneja título, mapa y propagación de contexto. **No calcula consumo.** |
| Fragmentos de consumo | `app/viajes-maint/webapp/ext/fragment/ConsumoPromedioMicroChart.fragment.xml`, `HeaderCharts.fragment.xml` | Muestran KPIs históricos en el header. |

**Conclusión:** toda la lógica de cálculo de gasoil reside en el backend. El frontend es prácticamente estándar Fiori Elements con pequeños widgets informativos.

---

## 3. Flujo de creación de un viaje (backend)

### 3.1 Archivos involucrados

- `srv/Viaje/service/viaje-service.cds` — proyección del servicio `Viajes`.
- `srv/Viaje/service/viaje-service.js` — handlers de negocio.
- `db/Viaje/viaje-schema.cds` — definición de la entidad `Viaje`.
- `srv/utils/rendimientoCalculator.js` — modelo de regresión para rendimiento teórico.

### 3.2 Eventos ejecutados al crear/editar

| Evento | Handler | Qué hace |
|--------|---------|----------|
| `before NEW` en `Viajes.drafts` | `srv/Viaje/service/viaje-service.js:176-185` | Inicializa `rendimientoTeorico`, `combustibleTeorico`, `costoTeorico` en `0`. Asigna número de viaje consecutivo. |
| `before UPDATE` en `Viajes.drafts` | `srv/Viaje/service/viaje-service.js:80-174` | Valida transiciones de estado. Calcula rendimiento, combustible y costo teóricos. Sincroniza `numeroViajeFormateado`. |
| `after READ` en `Viajes` | `srv/Viaje/service/viaje-service.js:13-65` | Calcula métricas históricas: consumo promedio de la ruta, últimos 3 consumos del vehículo en la ruta, etc. |
| `after READ` en `Viajes.drafts` | `srv/Viaje/service/viaje-service.js:69-78` | Sólo formatea el número de viaje. |

**Nota:** no existe un handler `before CREATE` en la entidad activa; todo el cálculo se hace sobre el **draft** durante la edición. Si el usuario guarda sin pasar por UPDATE (por ejemplo, carga masiva), los cálculos teóricos pueden quedar en `0`.

---

## 4. Cálculo del rendimiento y combustible teóricos

### 4.1 Fórmula implementada

```js
// srv/Viaje/service/viaje-service.js:138-168
const peso_total = Number(pesoIda) + Number(pesoVuelta);
const numero_ejes = ejescamion_code === 'TresEjes' ? 3 : 2;
const peso_por_eje = peso_total / numero_ejes;
const log_km = Math.log(ruta.distanciaKm);
const relacion_transmision = vehiculo.transmision.relacionTransmision;
const coeficiente_motor = vehiculo.motor.factorEficiencia;

const rendimientoRaw = calcularRendimiento({
  peso_por_eje,
  un_tramo_bool: !pesoVuelta || pesoVuelta == 0,
  ln_km: log_km,
  tres_ejes_bool: numero_ejes === 3,
  relacion_transmision,
  coeficiente_motor
});

const rendimientoTeorico = rendimientoRaw > 0 ? 1 / (rendimientoRaw / 1000) : 0;
const combustibleTeorico = rendimientoTeorico > 0 && distanciaKm > 0 ? distanciaKm / rendimientoTeorico : 0;

const precioCombustible = último precio del proveedor seleccionado;
const costoTeorico = combustibleTeorico * precioCombustible;
```

### 4.2 Modelo de regresión (`srv/utils/rendimientoCalculator.js`)

```text
R = 424.4919764
  + 0.004064368   × peso_por_eje
  - 15.40920943  × un_tramo
  - 22.29704349  × ln(km)
  + 25.01971995  × tres_ejes
  + 32.41757673  × relacion_transmision
  + coeficiente_motor
```

Coeficientes hardcodeados, sin fecha de calibración documentada ni métricas de precisión (R², intervalos de confianza).

### 4.3 Problemas identificados en el cálculo teórico

| # | Problema | Detalle | Impacto |
|---|----------|---------|---------|
| 1 | **Unidades confusas / documentación errónea** | El archivo de utilidad describe `R` como `km/L`, pero los coeficientes (intercepto ~424) sólo tienen sentido si `R` representa **litros consumidos por 1000 km**. Luego `rendimientoTeorico = 1 / (R/1000)` produce `km/L`. | Riesgo alto de que futuros desarrolladores usen mal el resultado. |
| 2 | **No se validan rangos de entrada** | No hay controles de `peso_por_eje`, `distanciaKm`, `relacionTransmision` fuera de rangos realistas. | Valores atípicos pueden generar rendimientos negativos o extremos. |
| 3 | **Dependencia de `pesoVuelta` para detectar tramo único** | `un_tramo_bool = !pesoVuelta \|\| pesoVuelta == 0`. Si `pesoVuelta` es `0` intencionalmente, se marca como ida y vuelta; si no se ingresa, se trata como un tramo. | El modelo puede aplicar una penalización de -15.4 L/1000km de forma incorrecta. |
| 4 | **No se usa `rendimientoBase` del vehículo** | El campo `Vehiculo.rendimientoBase` (Km/L nominal) existe en el modelo pero no entra en la fórmula. | Se desperdicia un dato útil para comparación y validación. |
| 5 | **Precio fijo por proveedor; sin histórico por fecha del viaje** | Se toma el último precio del proveedor (`orderBy fecha desc`), sin validar que corresponda a la fecha del viaje. | El costo teórico puede usarse con un precio de otra época. |
| 6 | **Cálculo solo en `UPDATE` de drafts** | Si un viaje se crea y guarda sin editar, los valores teóricos quedan en `0`. | Datos incompletos para reporting. |
| 7 | **No se calcula `consumoTeoricoTotal`** | El campo `Viaje.consumoTeoricoTotal` existe en el esquema pero nunca se asigna. | Inconsistencia entre esquema y lógica. |

---

## 5. Cálculo del consumo real (telemetría)

### 5.1 Archivo involucrado

- `srv/Telemetria/service/telemetria-service.js`

### 5.2 Lógica de recálculo

Cada vez que se crea, actualiza o elimina un registro de `Telemetria` vinculado a un viaje, se ejecuta `recalcularViaje(viajeId)`:

```js
// srv/Telemetria/service/telemetria-service.js:40-75
const niveles = telemetrias.map(t => t.nivelCombustible).filter(n => !isNaN(n));
const consumoRealTotal = Math.max(...niveles) - Math.min(...niveles);

let kilometrosRecorridos = 0;
for (cada par de puntos consecutivos) {
  if (velocidad > 5 km/h) {
    kilometrosRecorridos += distanciaHaversine(p1, p2);
  }
}
```

### 5.3 Problemas identificados en el consumo real

| # | Problema | Detalle | Impacto |
|---|----------|---------|---------|
| 1 | **No considera repostajes intermedios** | `max - min` asume que el nivel solo desciende. Si el vehículo carga combustible durante el viaje, el consumo real se subestima o queda incorrecto. | Métrica de consumo poco confiable para viajes largos con surtidos. |
| 2 | **No integra `SurtidoUnidad` con el viaje** | La entidad `SurtidoUnidad` no tiene asociación a `Viaje`, solo a `Vehiculo` y `OrdenCarga`. | No se puede sumar litros cargados al inicio o durante el viaje para ajustar el consumo. |
| 3 | **No se calculan `kilometrosPorLitro` ni `horasPorLitro`** | Estos campos existen en el esquema pero no se actualizan. | Los KPIs del Overview Page y reportes usan `kilometrosPorLitro` vacío. |
| 4 | **`litrosSalida` no se usa** | El campo existe en `Viaje` pero no se relaciona con el nivel de combustible del vehículo al inicio del viaje. | No se puede comparar consumo por punto de partida. |
| 5 | **Distancia real vs. distancia planificada** | Los kilómetros recorridos se calculan por Haversine, pero el rendimiento teórico usa `ruta.distanciaKm`. | Las comparaciones plan vs. real pueden no ser comparables. |
| 6 | **Recálculo sincrónico e ineficiente** | `recalcularViaje` hace un `SELECT` de todas las telemetrías y luego un `UPDATE` por cada mutación. Sin batching ni límite de registros. | Potencial problema de rendimiento si hay muchos registros de telemetría. |
| 7 | **Telemetría sin validación de calidad** | No se filtran valores anómalos de `nivelCombustible` o `velocidad`. | Un único dato erróneo puede distorsionar el consumo y la distancia. |

---

## 6. Integración con Órdenes de Carga y Surtidos

### 6.1 Orden de Carga (`OrdenCarga`)

- **Archivo:** `srv/OrdenCarga/service/orden-carga-service.js`
- **Lógica al crear/actualizar:**
  - Valida que la suma de los tanques detalle coincida con `carga_real`.
  - Verifica que cada tanque esté operativo y tenga capacidad disponible.
  - Actualiza el `nivel_actual` de cada tanque sumando la cantidad cargada.
  - Marca la primera orden activa por almacén (`isFirst = true`).
- **Cálculo de precio/variación:** se ejecuta solo en el handler `before UPDATE` de `OrdenesCarga.drafts` (no en `CREATE`). Calcula `precio = carga_real × último precio del proveedor` y `variacion = carga_facturada - carga_real`, `% conciliación`.

**Observación:** la `OrdenCarga` es una orden de **abastecimiento de tanques**, no de un viaje. No tiene relación directa con el consumo de gasoil de un vehículo.

### 6.2 Surtido de Unidad (`SurtidoUnidad`)

- **Archivo:** `srv/SurtidoUnidad/service/surtido-unidad-service.js`
- **Lógica al crear:**
  - Asocia automáticamente el surtido a la `OrdenCarga` activa del almacén (`isFirst = true`).
  - Valida capacidad del vehículo, tipo de combustible, nivel del tanque e inventario del almacén.
  - Actualiza `Vehiculo.nivelActualCombustible` sumando la carga.
  - Descuenta del tanque la cantidad surtida.
  - Cuando la suma de surtidos de una orden alcanza `carga_real`, marca la orden como no activa y activa la siguiente.

**Observación clave:** el surtido modifica el inventario del vehículo, pero **no está vinculado a un viaje**. Por tanto, el cálculo de consumo real de telemetría no puede compensar los litros cargados antes o durante un viaje.

---

## 7. Hallazgos críticos resumidos

1. **Modelo de rendimiento teórico poco transparente:** coeficientes hardcodeados, sin trazabilidad, con documentación de unidades contradictoria.
2. **Cálculo de consumo real frágil:** usa `max - min` de nivel de combustible sin considerar repostajes.
3. **Desconexión entre surtidos y viajes:** no se sabe cuánto combustible tenía el vehículo al inicio de un viaje ni cuánto se cargó durante el trayecto.
4. **Campos calculados inexistentes:** `consumoTeoricoTotal`, `kilometrosPorLitro`, `horasPorLitro` y `rendimientoReal` están en el modelo pero no se computan.
5. **Inconsistencia unidades:** el esquema dice `km/L` en algunos campos y `L` en otros, pero el cálculo mezcla L/1000km y km/L sin ser claro.
6. **Falta de tests:** no hay tests automatizados para validar ninguno de estos cálculos (`package.json` no tiene `test` y no existe carpeta `test/`).
7. **Riesgo de datos incompletos:** el cálculo teórico solo ocurre en `UPDATE` de drafts; creaciones directas quedan sin valores.

---

## 8. Recomendaciones para mejorar la funcionalidad

### 8.1 Modelo teórico de rendimiento

- **Documentar correctamente las unidades:** aclarar que el modelo predice `L/1000km` y que `rendimientoTeorico` se convierte a `km/L`.
- **Validar rangos de entrada:** evitar valores negativos o extremos de `peso_por_eje`, `distanciaKm`, etc.
- **Incluir `rendimientoBase` del vehículo** como factor adicional o como referencia de comparación.
- **Versionar los coeficientes:** almacenarlos en una tabla de configuración en lugar de hardcodearlos, con fecha de calibración y métricas de precisión.
- **Recalcular también en `before CREATE`** (o en la transición de draft a activo) para no depender de que el usuario edite el draft.

### 8.2 Cálculo del consumo real

- **Asociar surtidos al viaje:** agregar `viaje_ID` opcional en `SurtidoUnidad` para saber cuándo se cargó combustible durante un viaje.
- **Cálculo neto de consumo:** en lugar de `max - min`, usar:
  ```
  consumoReal = (nivelInicial + sumaSurtidosEnViaje) - nivelFinal
  ```
  Esto corrige el efecto de los repostajes.
- **Calcular `kilometrosPorLitro` y `horasPorLitro`:**
  - `km/L = kilometrosRecorridos / consumoRealTotal`
  - `horasPorLitro` podría calcularse a partir de tiempo a baja velocidad / consumo.
- **Registrar `litrosSalida`:** copiar el `nivelActualCombustible` del vehículo al crear el viaje (o al pasar a estado `EnCurso`).
- **Filtrado de datos anómalos:** descartar telemetrías con velocidad imposible, saltos geográficos bruscos o niveles de combustible inesperados.

### 8.3 Integración de datos

- **Unificar precios:** el costo teórico debería usar el precio vigente a la fecha del viaje, no simplemente el último del proveedor.
- **Costo real del viaje:** agregar un campo `costoReal` calculado a partir de `consumoRealTotal × precioCombustible` (del proveedor o del surtido).
- **Alertas de stock:** cuando el consumo real proyectado haga que el vehículo quede sin combustible antes de llegar, alertar al chofer/operador.

### 8.4 Calidad y mantenibilidad

- **Agregar tests unitarios** para `rendimientoCalculator`, `recalcularViaje` y los handlers de `SurtidoUnidad`.
- **Revisar el esquema CDS:** eliminar o poblar los campos calculados que hoy están vacíos (`consumoTeoricoTotal`, `kilometrosPorLitro`, etc.).
- **Auditoría:** agregar un log de cambios de nivel de combustible y surtidos para poder trazar el cálculo de consumo.

---

## 9. Plan de trabajo propuesto (para evolución incremental)

### Fase 1 — Corrección y claridad (1-2 semanas)
1. Corregir la documentación de unidades en `srv/utils/rendimientoCalculator.js`.
2. Validar rangos de entrada en el cálculo teórico.
3. Asegurar que el cálculo teórico se ejecute también al activar un viaje (no solo en `UPDATE` de draft).
4. Estandarizar el uso de `consumoTeoricoTotal` o eliminarlo del esquema.

### Fase 2 — Consumo real robusto (2-3 semanas)
1. Agregar `viaje_ID` opcional en `SurtidoUnidad` y propagarlo desde el frontend cuando corresponda.
2. Implementar cálculo neto de consumo considerando surtidos.
3. Calcular y persistir `kilometrosPorLitro`, `horasPorLitro` y `rendimientoReal`.
4. Registrar `litrosSalida` al inicio del viaje.

### Fase 3 — Integración y reporting (2-3 semanas)
1. Agregar `costoReal` del viaje.
2. Unificar la fuente de precios para costo teórico y real.
3. Actualizar las vistas de reporting (`OverviewPage`, `ReportingService`) para que usen los nuevos campos.
4. Implementar alertas de consumo/desvío.

### Fase 4 — Calidad y modelado (2-3 semanas)
1. Crear tests unitarios para los cálculos de gasoil.
2. Mover coeficientes del modelo a una entidad configurable con versión.
3. Re-entrenar/revisar el modelo con datos históricos reales de telemetría.

---

## 10. Anexos: referencias rápidas de archivos

| Concepto | Archivo principal |
|----------|---------------------|
| Entidad `Viaje` | `db/Viaje/viaje-schema.cds` |
| Proyección del servicio | `srv/Viaje/service/viaje-service.cds` |
| Handlers de creación/edición | `srv/Viaje/service/viaje-service.js` |
| Modelo de rendimiento | `srv/utils/rendimientoCalculator.js` |
| Consumo real por telemetría | `srv/Telemetria/service/telemetria-service.js` |
| Entidad `SurtidoUnidad` | `db/SurtidoUnidad/surtido-unidad-schema.cds` |
| Lógica de surtidos | `srv/SurtidoUnidad/service/surtido-unidad-service.js` |
| Entidad `OrdenCarga` | `db/OrdenCarga/orden-carga-schema.cds` |
| Lógica de órdenes de carga | `srv/OrdenCarga/service/orden-carga-service.js` |
| App Fiori de viajes | `app/viajes-maint/webapp/manifest.json` |
| Launchpad (tile “Orden de trabajo”) | `app/index.html:39` |

---

*Fin del informe.*
