using { ReportingService } from '../service/reporting-service';

annotate ReportingService.HechosViaje with @(UI: {

  HeaderInfo: {
    TypeName: 'Viaje',
    TypeNamePlural: 'Viajes',
    Title: { Value: placaVehiculo },
    Description: { Value: descripcionRuta }
  },

  SelectionFields: [
    fecha,
    anio,
    mes,
    trimestre,
    semanaAnio,
    esFinDeSemana,
    placaVehiculo,
    modeloVehiculo,
    vehiculo_ID,
    nombreChofer,
    chofer_ID,
    descripcionRuta,
    ruta_ID,
    esViajeCorto,
    esViajeLargo,
    estadoViaje,
    esFinalizado,
    esCancelado,
    cumpleRendimientoTeorico,
    eficienciaCategoria,
    esSobrecarga,
    pesoTotal,
    nombreProveedor,
    nombreAlmacen,
    nombreRubro
  ],

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
    { Value: costoTeorico,         Label: 'Costo Teórico' },
    { Value: costoPorKm,           Label: 'Costo/km' },
    { Value: estadoViaje,          Label: 'Estado' },
    { Value: eficienciaCategoria,  Label: 'Eficiencia' }
  ],

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
  variacionRendimientoPct @UI.Criticality: variacionCriticality;
};

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
    { Value: costoTotal,         Label: 'Costo Total' },
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

annotate ReportingService.AggMensual with {
  distanciaTotalKm     @Measures.Unit: 'km';
  combustibleRealTotal @Measures.Unit: 'L';
  costoTotal           @Measures.ISOCurrency: 'USD';
  rendimientoPromedio  @Measures.Unit: 'km/L';
};
