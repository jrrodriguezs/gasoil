# Propuesta: Modelo de Datos Ampliado para Reportología y Minería de Datos

> **Proyecto:** GAS-APP | **Fecha:** 2026-07-12 | **Versión:** 1.0

---

## 1. Visión General

### Objetivo
Crear una **capa de reporting** sobre el modelo transaccional existente que permita:
1. **List Report unificado** con filtros multidimensionales y línea de tiempo
2. **Análisis exploratorio** sin impactar el modelo operacional
3. **Base para minería de datos** (machine learning, predicción de consumo, clustering de rutas)

### Principios de diseño
- **Separación de responsabilidades:** El modelo operacional sigue siendo el maestro; el modelo de reporting es derivado
- **Desnormalización controlada:** Las vistas de reporting incluyen claves foráneas resueltas como atributos textuales
- **Dimensiones conformadas:** Tiempo, vehículo, chofer, ruta son dimensiones reutilizables
- **Grano atómico:** Cada registro del hecho representa un viaje individual (no agregado)

---

## 2. Arquitectura del Modelo de Reporting

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      CAPA DE REPORTING (CAP CDS)                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐   │
│   │   DimTiempo     │     │   DimVehiculo   │     │   DimChofer     │   │
│   │   (Time Dim)    │     │   (Slowly Chg)  │     │   (Slowly Chg)  │   │
│   └────────┬────────┘     └────────┬────────┘     └────────┬────────┘   │
│            │                       │                       │            │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                         HechoViaje                               │   │
│   │   (Fact Table — grano: 1 registro por viaje)                    │   │
│   │                                                                  │   │
│   │   Claves: fechaKey, vehiculo_ID, chofer_ID, ruta_ID, ...        │   │
│   │   Métricas: distancia, consumo, costo, rendimiento, variación   │   │
│   │   Flags: estadoViaje, esSobrecarga, esViajeCorto, cumpleTeorico │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│            │                       │                       │            │
│   ┌────────┴────────┐     ┌────────┴────────┐     ┌────────┴────────┐   │
│   │   DimRuta       │     │   DimMotor      │     │   DimAlmacen    │   │
│   │   (Geográfica)  │     │   (Técnica)     │     │   (Operativa)   │   │
│   └─────────────────┘     └─────────────────┘     └─────────────────┘   │
│                                                                          │
│   ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐   │
│   │  V_AggMensual   │     │  V_AggPorRuta   │     │  V_AggPorChofer │   │
│   │  (Pre-agregada) │     │  (Pre-agregada) │     │  (Pre-agregada) │   │
│   └─────────────────┘     └─────────────────┘     └─────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         MODELO OPERACIONAL                               │
│              (Vehiculo, Viaje, Chofer, Ruta, Motor, etc.)                │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Dimensiones (Entidades de Soporte)

### 3.1 DimTiempo — Dimensión Calendario

> **Propósito:** Permitir análisis por cualquier granularidad temporal sin cálculos en runtime.

```cds
// db/Reporting/dim-tiempo.cds
namespace gas.reporting;

entity DimTiempo {
  key dateKey     : String(8);     // YYYYMMDD — clave surrogate
      fecha       : Date;
      anio        : Integer;
      mes         : Integer;
      dia         : Integer;
      trimestre   : Integer;       // 1, 2, 3, 4
      semanaAnio  : Integer;       // ISO week 1-53
      diaSemana   : Integer;       // 1=Lunes, 7=Domingo
      nombreMes   : String(10);    // "Enero", "Febrero"...
      nombreDia   : String(10);    // "Lunes", "Martes"...
      esFinDeSemana : Boolean;
      esFeriado   : Boolean;
      periodoYMD  : String(6);     // YYYYMM
      periodoYQT  : String(7);     // YYYY-Q1
      diasDesdeInicioAnio : Integer;
      diasHastaFinAnio    : Integer;
};
```

**Carga:** Se genera con un script SQL/Python una vez al año (o con un stored procedure). No es transaccional.

### 3.2 DimVehiculo — Dimensión Vehículo (Snapshot)

> **Propósito:** Congelar atributos del vehículo al momento del viaje para análisis histórico consistente.

```cds
// db/Reporting/dim-vehiculo.cds
namespace gas.reporting;

entity DimVehiculo {
  key vehiculo_ID   : UUID;
      placa         : String;
      modelo        : String;
      motorModelo   : String;
      transmisionModelo : String;
      cajaModelo    : String;
      ejes          : String;
      configuracion : String;
      capacidadTotal : Decimal(10,2);
      estado        : String;
      // Atributos para clustering/minería
      antiguedadDias : Integer;    // Días desde createdAt
      categoriaCarga : String;     // "Ligera", "Media", "Pesada"
};
```

### 3.3 DimChofer — Dimensión Chofer

```cds
// db/Reporting/dim-chofer.cds
namespace gas.reporting;

entity DimChofer {
  key chofer_ID     : UUID;
      nombreCompleto : String;
      cedula        : String;
      rendimientoQual : String;    // "Bueno", "Regular", "Malo"
      viajesTotales : Integer;     // Conteo acumulado
      experienciaMeses : Integer;  // Meses desde el primer viaje
};
```

### 3.4 DimRuta — Dimensión Geográfica

```cds
// db/Reporting/dim-ruta.cds
namespace gas.reporting;

entity DimRuta {
  key ruta_ID       : UUID;
      descripcion   : String;
      distanciaKm   : Decimal(10,2);
      destinosCount : Integer;
      latitudOrigen : Decimal(9,6);
      longitudOrigen: Decimal(9,6);
      latitudDestino: Decimal(9,6);
      longitudDestino: Decimal(9,6);
      // Atributos para minería
      categoriaDistancia : String;  // "Corta (<100km)", "Media", "Larga"
      complejidadRuta    : Integer; // Basado en cantidad de puntos/coordenadas
};
```

### 3.5 DimProveedor — Dimensión de Combustible

```cds
// db/Reporting/dim-proveedor.cds
namespace gas.reporting;

entity DimProveedor {
  key proveedor_ID  : UUID;
      nombre        : String;
      capacidadDespacho : Decimal(10,2);
      precioPromedio : Decimal(10,2);   // Último precio histórico
};
```

### 3.6 DimAlmacen — Dimensión Operativa

```cds
// db/Reporting/dim-almacen.cds
namespace gas.reporting;

entity DimAlmacen {
  key almacen_ID    : UUID;
      nombreSede    : String;
      ubicacion     : String;
      estado        : String;
      capacidadTotal : Decimal(10,2);
      tanquesCount  : Integer;
};
```

---

## 4. Tabla de Hechos — HechoViaje

> **Grano:** Un registro por cada viaje completado o en curso.
> **Fuente:** Entidad `Viaje` + navegaciones + cálculos derivados.

```cds
// db/Reporting/hecho-viaje.cds
namespace gas.reporting;

using { gas.app.Viaje } from '../Viaje/viaje-schema';
using { gas.reporting.DimTiempo } from './dim-tiempo';

@Analytics.dataCategory: #FACT
entity HechoViaje {
  // ─── Claves naturales ───
  key viaje_ID        : UUID;
      vehiculo_ID     : UUID;
      chofer_ID       : UUID;
      ruta_ID         : UUID;
      motor_ID        : UUID;
      transmision_ID  : UUID;
      caja_ID         : UUID;
      proveedor_ID    : UUID;
      almacen_ID      : UUID;
      rubro_ID        : UUID;

  // ─── Dimensiones resueltas (textos para filtrado rápido) ───
      placaVehiculo   : String;
      modeloVehiculo  : String;
      nombreChofer    : String;
      descripcionRuta : String;
      nombreProveedor : String;
      nombreAlmacen   : String;
      nombreRubro     : String;

  // ─── Dimensión Tiempo ───
      fechaKey        : String(8);      // FK a DimTiempo
      fecha           : Date;
      anio            : Integer;
      mes             : Integer;
      trimestre       : Integer;
      semanaAnio      : Integer;
      diaSemana       : Integer;
      nombreMes       : String;
      esFinDeSemana   : Boolean;

  // ─── Métricas de distancia y tiempo ───
      distanciaKm     : Decimal(10,2);  // De Ruta
      kilometrosRecorridos : Decimal(10,2);
      horasSalida     : Time;
      horasLlegada    : Time;
      horasLlegadaReal: Time;
      duracionHoras   : Decimal(5,2);   // Calculado: llegadaReal - salida
      duracionTeoricaHoras : Decimal(5,2); // distancia / velocidadPromedioEsperada

  // ─── Métricas de combustible ───
      litrosSalida    : Decimal(10,2);
      consumoRealTotal : Decimal(10,2);
      consumoTeoricoTotal : Decimal(10,2);
      combustibleTeorico  : Decimal(10,2);  // Del modelo de regresión
      costoTeorico    : Decimal(10,2);
      precioCombustible : Decimal(10,2);    // Precio al momento del viaje

  // ─── Métricas de rendimiento ───
      rendimientoReal : Decimal(10,2);     // km/L real
      rendimientoTeorico : Decimal(10,2);  // km/L teórico
      variacionRendimientoPct : Decimal(5,2); // (real-teórico)/teórico * 100
      kilometrosPorLitro : Decimal(5,2);   // Alias de rendimientoReal
      horasPorLitro   : Decimal(5,2);

  // ─── Métricas de carga ───
      pesoCarga       : Decimal(10,2);
      pesoIda         : Decimal(10,2);
      pesoVuelta      : Decimal(10,2);
      pesoTotal       : Decimal(10,2);     // pesoIda + pesoVuelta
      toneladasPorKm  : Decimal(10,2);     // pesoTotal * distanciaKm / 1000

  // ─── Flags calculados (para minería y filtros) ───
      estadoViaje     : String;            // "Programado", "EnCurso", "Finalizado", "Cancelado"
      esFinalizado    : Boolean;
      esCancelado     : Boolean;
      cumpleRendimientoTeorico : Boolean;  // variacionRendimientoPct >= -5%
      esSobrecarga    : Boolean;           // pesoTotal > capacidadVehiculo * 0.9
      esViajeCorto    : Boolean;           // distanciaKm < 50
      esViajeLargo    : Boolean;           // distanciaKm > 500
      eficienciaCategoria : String;        // "Excelente", "Buena", "Regular", "Mala"
      costoPorKm      : Decimal(10,2);     // costoTeorico / distanciaKm
      costoPorToneladaKm : Decimal(10,4);  // costoTeorico / toneladasPorKm

  // ─── Métricas de telemetría (agregadas) ───
      velocidadPromedio : Decimal(5,2);
      velocidadMaxima   : Decimal(5,2);
      altitudPromedio   : Decimal(6,2);
      registrosTelemetria : Integer;

  // ─── Auditoría ───
      createdAt       : Timestamp;
      modifiedAt      : Timestamp;
};
```

---

## 5. Vistas Agregadas Precomputadas

### 5.1 Vista Mensual (para dashboards de tendencia)

```cds
// db/Reporting/vistas-agregadas.cds
namespace gas.reporting;

@Analytics.dataCategory: #AGGREGATION
entity V_AggMensual as select from HechoViaje {
  key anio,
  key mes,
  key nombreMes,
      periodoYMD,       // YYYYMM
      count(*)           as cantidadViajes      : Integer,
      sum(distanciaKm)   as distanciaTotalKm    : Decimal(12,2),
      sum(consumoRealTotal) as combustibleRealTotal : Decimal(12,2),
      sum(consumoTeoricoTotal) as combustibleTeoricoTotal : Decimal(12,2),
      sum(costoTeorico)  as costoTotal          : Decimal(12,2),
      avg(rendimientoReal) as rendimientoPromedio : Decimal(10,2),
      avg(variacionRendimientoPct) as variacionPromedioPct : Decimal(5,2),
      sum(toneladasPorKm) as toneladasKmTotal   : Decimal(12,2)
} where esFinalizado = true
  group by anio, mes, nombreMes, periodoYMD;
```

### 5.2 Vista por Vehículo y Ruta

```cds
entity V_AggPorVehiculoRuta as select from HechoViaje {
  key placaVehiculo,
  key descripcionRuta,
      count(*)           as cantidadViajes      : Integer,
      sum(distanciaKm)   as distanciaTotalKm    : Decimal(12,2),
      avg(rendimientoReal) as rendimientoPromedio : Decimal(10,2),
      avg(variacionRendimientoPct) as variacionPromedio : Decimal(5,2),
      sum(costoTeorico)  as costoTotal          : Decimal(12,2)
} where esFinalizado = true
  group by placaVehiculo, descripcionRuta;
```

### 5.3 Vista por Chofer (para evaluación de desempeño)

```cds
entity V_AggPorChofer as select from HechoViaje {
  key nombreChofer,
  key cedulaChofer,
      count(*)           as cantidadViajes      : Integer,
      sum(distanciaKm)   as distanciaTotalKm    : Decimal(12,2),
      avg(rendimientoReal) as rendimientoPromedio : Decimal(10,2),
      avg(variacionRendimientoPct) as variacionPromedio : Decimal(5,2),
      sum(costoTeorico)  as costoTotal          : Decimal(12,2),
      // Flags para identificar patrones
      sum(case when cumpleRendimientoTeorico then 1 else 0 end) as viajesExitosos : Integer,
      round(100.0 * sum(case when cumpleRendimientoTeorico then 1 else 0 end) / count(*), 2)
                         as tasaExitoPct        : Decimal(5,2)
} where esFinalizado = true
  group by nombreChofer, cedulaChofer;
```

### 5.4 Vista por Componente Técnico

```cds
entity V_AggPorComponente as select from HechoViaje {
  key motor_ID,
  key transmision_ID,
  key caja_ID,
      placaVehiculo,
      count(*)           as cantidadViajes      : Integer,
      avg(rendimientoReal) as rendimientoPromedio : Decimal(10,2),
      avg(pesoTotal)     as pesoPromedio        : Decimal(10,2),
      avg(costoPorKm)    as costoPromedioPorKm  : Decimal(10,2)
} where esFinalizado = true
  group by motor_ID, transmision_ID, caja_ID, placaVehiculo;
```

---

## 6. Servicio CDS de Reporting

```cds
// srv/Reporting/service/reporting-service.cds
using { gas.reporting } from '../../../db/Reporting/hecho-viaje';

service ReportingService {

  // ─── Hecho principal (List Report) ───
  @readonly
  entity HechosViaje as projection on reporting.HechoViaje;

  // ─── Dimensiones (para filtros y ValueHelp) ───
  @readonly
  entity DimensionTiempo as projection on reporting.DimTiempo;

  @readonly
  entity DimensionVehiculo as projection on reporting.DimVehiculo;

  @readonly
  entity DimensionChofer as projection on reporting.DimChofer;

  @readonly
  entity DimensionRuta as projection on reporting.DimRuta;

  @readonly
  entity DimensionProveedor as projection on reporting.DimProveedor;

  @readonly
  entity DimensionAlmacen as projection on reporting.DimAlmacen;

  // ─── Vistas agregadas (para gráficos y KPIs) ───
  @readonly
  entity AggMensual as projection on reporting.V_AggMensual;

  @readonly
  entity AggPorVehiculoRuta as projection on reporting.V_AggPorVehiculoRuta;

  @readonly
  entity AggPorChofer as projection on reporting.V_AggPorChofer;

  @readonly
  entity AggPorComponente as projection on reporting.V_AggPorComponente;

  // ─── Actions para minería de datos ───
  action predecirConsumo(
    vehiculo_ID : UUID,
    ruta_ID     : UUID,
    pesoTotal   : Decimal(10,2)
  ) returns {
    consumoEstimado : Decimal(10,2);
    confianzaPct    : Decimal(5,2);
    modeloUsado     : String;
  };

  action clusterizarRutas() returns array of {
    clusterID       : Integer;
    descripcion     : String;
    cantidadRutas   : Integer;
    distanciaPromedio : Decimal(10,2);
    rendimientoPromedio : Decimal(10,2);
  };
};
```

---

## 7. Anotaciones Fiori para List Report

```cds
// srv/Reporting/annotations/annotations-reporting.cds
using { ReportingService } from '../service/reporting-service';

annotate ReportingService.HechosViaje with @(UI: {

  // ─── Página principal: List Report ───
  HeaderInfo: {
    TypeName: 'Viaje',
    TypeNamePlural: 'Viajes',
    Title: { Value: placaVehiculo },
    Description: { Value: descripcionRuta }
  },

  // ─── FILTROS (SelectionFields) ───
  // Todos los campos posibles para filtrar
  SelectionFields: [
    // ── Filtros de tiempo ──
    fecha,
    anio,
    mes,
    trimestre,
    semanaAnio,
    esFinDeSemana,

    // ── Filtros de vehículo ──
    placaVehiculo,
    modeloVehiculo,
    vehiculo_ID,

    // ── Filtros de chofer ──
    nombreChofer,
    chofer_ID,

    // ── Filtros de ruta ──
    descripcionRuta,
    ruta_ID,
    esViajeCorto,
    esViajeLargo,

    // ── Filtros de combustible / rendimiento ──
    estadoViaje,
    esFinalizado,
    esCancelado,
    cumpleRendimientoTeorico,
    eficienciaCategoria,

    // ── Filtros de carga ──
    esSobrecarga,
    pesoTotal,

    // ── Filtros de proveedor / almacén ──
    nombreProveedor,
    nombreAlmacen,
    nombreRubro
  ],

  // ─── COLUMNAS (LineItem) ───
  LineItem: [
    { Value: fecha,                Label: 'Fecha' },
    { Value: placaVehiculo,        Label: 'Placa' },
    { Value: nombreChofer,         Label: 'Chofer' },
    { Value: descripcionRuta,      Label: 'Ruta' },
    { Value: distanciaKm,          Label: 'Distancia (km)' },
    { Value: pesoTotal,            Label: 'Peso Total (kg)' },
    { Value: litrosSalida,         Label: 'Litros Salida' },
    { Value: consumoRealTotal,     Label: 'Consumo Real (L)' },
    { Value: consumoTeoricoTotal,  Label: 'Consumo Teórico (L)' },
    { Value: rendimientoReal,      Label: 'Rend. Real (km/L)' },
    { Value: rendimientoTeorico,   Label: 'Rend. Teórico (km/L)' },
    { Value: variacionRendimientoPct, Label: 'Variación (%)' },
    { Value: costoTeorico,         Label: 'Costo Teórico ($)' },
    { Value: costoPorKm,           Label: 'Costo/km ($)' },
    { Value: estadoViaje,          Label: 'Estado' },
    { Value: eficienciaCategoria,  Label: 'Eficiencia' }
  ],

  // ─── Variantes de presentación ───
  PresentationVariant #Default: {
    SortOrder: [
      { Property: fecha, Descending: true },
      { Property: placaVehiculo }
    ],
    Visualizations: ['@UI.LineItem']
  },

  PresentationVariant #PorRendimiento: {
    SortOrder: [
      { Property: rendimientoReal, Descending: true }
    ],
    Visualizations: ['@UI.LineItem']
  },

  PresentationVariant #PorCosto: {
    SortOrder: [
      { Property: costoPorKm, Descending: true }
    ],
    Visualizations: ['@UI.LineItem']
  }
});

// ─── Anotaciones de medidas y unidades ───
annotate ReportingService.HechosViaje with {
  distanciaKm            @Measures.Unit: 'km';
  kilometrosRecorridos   @Measures.Unit: 'km';
  litrosSalida           @Measures.Unit: 'L';
  consumoRealTotal       @Measures.Unit: 'L';
  consumoTeoricoTotal    @Measures.Unit: 'L';
  combustibleTeorico     @Measures.Unit: 'L';
  rendimientoReal        @Measures.Unit: 'km/L';
  rendimientoTeorico     @Measures.Unit: 'km/L';
  costoTeorico           @Measures.ISOCurrency: 'USD';
  costoPorKm             @Measures.ISOCurrency: 'USD';
  pesoCarga              @Measures.Unit: 'kg';
  pesoTotal              @Measures.Unit: 'kg';
};

// ─── Criticality para variación de rendimiento ───
annotate ReportingService.HechosViaje with {
  variacionRendimientoPct @UI.Criticality: variacionCriticality;
};

// Campo virtual para criticality
annotate ReportingService.HechosViaje with @cds.persistence.skip: false;

// ─── Anotaciones para vistas agregadas ───
annotate ReportingService.AggMensual with @(UI: {
  HeaderInfo: {
    TypeName: 'Métrica Mensual',
    TypeNamePlural: 'Métricas Mensuales'
  },
  LineItem: [
    { Value: periodoYMD,         Label: 'Período' },
    { Value: cantidadViajes,     Label: 'Viajes' },
    { Value: distanciaTotalKm,   Label: 'Distancia Total (km)' },
    { Value: combustibleRealTotal, Label: 'Combustible Real (L)' },
    { Value: costoTotal,         Label: 'Costo Total ($)' },
    { Value: rendimientoPromedio, Label: 'Rend. Promedio (km/L)' },
    { Value: variacionPromedioPct, Label: 'Variación Promedio (%)' }
  ],
  Chart #TendenciaMensual: {
    ChartType: #Combination,
    Dimensions: [nombreMes],
    DimensionAttributes: [{ Dimension: nombreMes, Role: #Category }],
    Measures: [cantidadViajes, distanciaTotalKm, combustibleRealTotal],
    MeasureAttributes: [
      { Measure: cantidadViajes, Role: #Axis1 },
      { Measure: distanciaTotalKm, Role: #Axis2 },
      { Measure: combustibleRealTotal, Role: #Axis3 }
    ]
  }
});
```

---

## 8. Script de Población (Node.js)

> **Propósito:** Mantener `HechoViaje` sincronizado con los datos transaccionales.
> **Frecuencia:** Diaria (noche) o en tiempo real vía handlers.

```javascript
// srv/Reporting/service/reporting-sync.js
const cds = require('@sap/cds');

/**
 * Sincroniza la tabla de hechos a partir de los viajes existentes.
 * Se recomienda ejecutar como job programado (cron) una vez al día.
 */
async function sincronizarHechosViaje() {
  const tx = cds.transaction();
  const { Viajes } = cds.entities('gas.app');
  const { HechoViaje } = cds.entities('gas.reporting');

  try {
    // 1. Limpiar hechos existentes (o usar upsert)
    await tx.run(DELETE.from(HechoViaje));

    // 2. Leer todos los viajes con navegaciones
    const viajes = await tx.run(
      SELECT.from(Viajes, v => {
        v('*'),
        v.vehiculo(vh => { vh('*'), vh.motor('*'), vh.transmision('*'), vh.caja('*') }),
        v.chofer('*'),
        v.ruta('*'),
        v.proveedor('*'),
        v.rubro('*')
      })
    );

    // 3. Transformar y calcular flags
    const hechos = viajes.map(v => {
      const pesoTotal = (v.pesoIda || 0) + (v.pesoVuelta || 0);
      const rendimientoReal = v.kilometrosPorLitro || 0;
      const rendimientoTeorico = v.rendimientoTeorico || 0;
      const variacion = rendimientoTeorico > 0
        ? ((rendimientoReal - rendimientoTeorico) / rendimientoTeorico) * 100
        : 0;

      return {
        viaje_ID: v.ID,
        vehiculo_ID: v.vehiculo_ID,
        chofer_ID: v.chofer_ID,
        ruta_ID: v.ruta_ID,
        motor_ID: v.vehiculo?.motor_ID,
        transmision_ID: v.vehiculo?.transmision_ID,
        caja_ID: v.vehiculo?.caja_ID,
        proveedor_ID: v.proveedor_ID,
        rubro_ID: v.rubro_ID,

        placaVehiculo: v.vehiculo?.placa,
        modeloVehiculo: v.vehiculo?.modelo,
        nombreChofer: v.chofer ? `${v.chofer.nombre} ${v.chofer.apellido}` : null,
        descripcionRuta: v.ruta?.descripcion,
        nombreProveedor: v.proveedor?.nombre,
        nombreRubro: v.rubro?.name,

        fecha: v.fecha,
        anio: v.fecha ? parseInt(v.fecha.substring(0, 4)) : null,
        mes: v.fecha ? parseInt(v.fecha.substring(5, 7)) : null,
        trimestre: v.fecha ? Math.ceil(parseInt(v.fecha.substring(5, 7)) / 3) : null,

        distanciaKm: v.ruta?.distanciaKm,
        kilometrosRecorridos: v.kilometrosRecorridos,
        litrosSalida: v.litrosSalida,
        consumoRealTotal: v.consumoRealTotal,
        consumoTeoricoTotal: v.consumoTeoricoTotal,
        combustibleTeorico: v.combustibleTeorico,
        costoTeorico: v.costoTeorico,

        rendimientoReal,
        rendimientoTeorico,
        variacionRendimientoPct: variacion,
        kilometrosPorLitro: v.kilometrosPorLitro,
        horasPorLitro: v.horasPorLitro,

        pesoCarga: v.pesoCarga,
        pesoIda: v.pesoIda,
        pesoVuelta: v.pesoVuelta,
        pesoTotal,

        estadoViaje: v.estatus,
        esFinalizado: v.estatus === 'Finalizado',
        esCancelado: v.estatus === 'Cancelado',
        cumpleRendimientoTeorico: variacion >= -5,
        esSobrecarga: pesoTotal > (v.vehiculo?.capacidadTotal || 0) * 0.9,
        esViajeCorto: (v.ruta?.distanciaKm || 0) < 50,
        esViajeLargo: (v.ruta?.distanciaKm || 0) > 500,
        eficienciaCategoria: variacion >= 0 ? 'Excelente' :
                             variacion >= -5 ? 'Buena' :
                             variacion >= -15 ? 'Regular' : 'Mala',
        costoPorKm: v.costoTeorico > 0 && v.ruta?.distanciaKm > 0
          ? v.costoTeorico / v.ruta.distanciaKm : 0,

        createdAt: v.createdAt,
        modifiedAt: v.modifiedAt
      };
    });

    // 4. Insertar en batch
    if (hechos.length > 0) {
      await tx.run(INSERT.into(HechoViaje).entries(hechos));
    }

    await tx.commit();
    console.log(`[Reporting] ${hechos.length} hechos sincronizados.`);
    return { sincronizados: hechos.length };

  } catch (err) {
    await tx.rollback();
    console.error('[Reporting] Error en sincronización:', err);
    throw err;
  }
}

module.exports = { sincronizarHechosViaje };
```

---

## 9. Recomendaciones para Minería de Datos

### 9.1 Features listas para ML

El modelo `HechoViaje` ya incluye features calculadas que pueden alimentar modelos de machine learning:

| Feature | Tipo | Uso sugerido |
|---------|------|-------------|
| `distanciaKm` | Numérica | Regresión de consumo |
| `pesoTotal` | Numérica | Regresión de consumo |
| `esViajeCorto` | Boolean | Clasificación de tipo de viaje |
| `esSobrecarga` | Boolean | Detección de anomalías |
| `variacionRendimientoPct` | Numérica | Target para predicción |
| `diaSemana` | Categórica | Patrones temporales |
| `esFinDeSemana` | Boolean | Patrones temporales |
| `motor_ID` | Categórica | Clustering de componentes |
| `velocidadPromedio` | Numérica | Eficiencia de conducción |

### 9.2 Casos de uso de ML

1. **Predicción de consumo:** Entrenar un modelo de regresión (Random Forest, XGBoost) con `distanciaKm`, `pesoTotal`, `motor_ID`, `transmision_ID` como features y `consumoRealTotal` como target.

2. **Detección de anomalías:** Identificar viajes donde `variacionRendimientoPct < -20%` como posibles fugas, robos o errores de medición.

3. **Clustering de rutas:** Agrupar rutas por `distanciaKm`, `destinosCount`, `velocidadPromedio` para identificar patrones de eficiencia.

4. **Predicción de mantenimiento:** Correlacionar `rendimientoReal` degradado con `antiguedadDias` del vehículo y kilómetros acumulados.

### 9.3 Integración con Python

```python
# Ejemplo: script de análisis con pandas/scikit-learn
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split

# Leer desde PostgreSQL (o exportar CSV desde HechoViaje)
df = pd.read_sql("SELECT * FROM gas_reporting_hechoviaje WHERE es_finalizado = true", conn)

# Features y target
X = df[['distanciaKm', 'pesoTotal', 'velocidadPromedio', 'anio', 'mes']]
y = df['consumoRealTotal']

# Entrenar
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
modelo = RandomForestRegressor(n_estimators=100)
modelo.fit(X_train, y_train)

# Evaluar
print(f"R²: {modelo.score(X_test, y_test)}")
```

---

## 10. Plan de Implementación

### Fase 1: Crear estructura (2-3 días)
- [ ] Crear carpeta `db/Reporting/`
- [ ] Implementar `DimTiempo` + script de generación
- [ ] Implementar `HechoViaje` (tabla de hechos)
- [ ] Implementar vistas agregadas (`V_AggMensual`, `V_AggPorChofer`, etc.)
- [ ] Implementar `ReportingService` en `srv/Reporting/`
- [ ] Crear aplicación Fiori `reporting-list`

### Fase 2: Población inicial (1-2 días)
- [ ] Ejecutar script de sincronización histórica
- [ ] Validar datos: sumas, promedios, conteos
- [ ] Verificar performance de consultas (índices en PostgreSQL)

### Fase 3: Automatización (1 día)
- [ ] Crear cron job nocturno para sincronización incremental
- [ ] O implementar triggers CDS (`after CREATE/UPDATE/DELETE` en `Viajes`) para actualización en tiempo real

### Fase 4: Minería de datos (3-5 días)
- [ ] Exportar dataset CSV desde `HechoViaje`
- [ ] Entrenar modelo base de predicción de consumo
- [ ] Implementar action `predecirConsumo` en `ReportingService`
- [ ] Documentar hallazgos

---

## 11. Diagrama ER del Modelo de Reporting

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   DimTiempo     │       │   DimVehiculo   │       │   DimChofer     │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ PK dateKey      │       │ PK vehiculo_ID  │       │ PK chofer_ID    │
│    fecha        │       │    placa        │       │    nombreCompleto│
│    anio         │       │    modelo       │       │    cedula       │
│    mes          │       │    motorModelo  │       │    rendimientoQual│
│    trimestre    │       │    transmision  │       │    viajesTotales│
│    semanaAnio   │       │    cajaModelo   │       └─────────────────┘
│    diaSemana    │       │    ejes         │              │
│    esFinDeSemana│       │    estado       │              │
└────────┬────────┘       └────────┬────────┘              │
         │                         │                       │
         │    ┌─────────────────────────────────────────────────────────┐
         │    │                    HechoViaje                           │
         │    ├─────────────────────────────────────────────────────────┤
         │    │ PK viaje_ID                                             │
         │    │ FK fechaKey ────────► DimTiempo                         │
         │    │ FK vehiculo_ID ─────► DimVehiculo                       │
         └───►│ FK chofer_ID ───────► DimChofer                         │
              │ FK ruta_ID ─────────► DimRuta                           │
              │ FK proveedor_ID ────► DimProveedor                       │
              │ FK almacen_ID ──────► DimAlmacen                         │
              │                                                         │
              │    fecha, placaVehiculo, nombreChofer, descripcionRuta  │
              │    anio, mes, trimestre, semanaAnio, diaSemana          │
              │                                                         │
              │    distanciaKm, kilometrosRecorridos, litrosSalida      │
              │    consumoRealTotal, consumoTeoricoTotal, costoTeorico  │
              │    rendimientoReal, rendimientoTeorico                  │
              │    variacionRendimientoPct, eficienciaCategoria         │
              │                                                         │
              │    pesoCarga, pesoTotal, esSobrecarga                   │
              │    estadoViaje, esFinalizado, esCancelado               │
              │    cumpleRendimientoTeorico, costoPorKm                 │
              │                                                         │
              └─────────────────────────────────────────────────────────┘
```

---

*Propuesta generada a partir del análisis arquitectónico del modelo GAS-APP.*
