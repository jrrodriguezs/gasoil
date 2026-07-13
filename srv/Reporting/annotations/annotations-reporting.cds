using { ReportingService } from '../service/reporting-service';

annotate ReportingService.HechosViaje with @Capabilities: {
  FilterRestrictions: {
    FilterExpressionRestrictions: [
      { Property: fecha, AllowedExpressions: 'SingleRange' }
    ]
  }
};

annotate ReportingService.HechosViaje with @(UI: {

  HeaderInfo: {
    TypeName: 'Viaje',
    TypeNamePlural: 'Viajes',
    Title: { Value: placaVehiculo },
    Description: { Value: descripcionRuta }
  },

  SelectionFields: [
    // Tiempo
    fecha,
    fechaKey,
    anio,
    mes,
    trimestre,
    semanaAnio,
    diaSemana,
    nombreMes,
    esFinDeSemana,
    periodoYMD,
    periodoYQT,

    // Vehículo y componentes
    vehiculo_ID,
    placaVehiculo,
    modeloVehiculo,
    motor_ID,
    transmision_ID,
    caja_ID,

    // Chofer
    chofer_ID,
    nombreChofer,
    cedulaChofer,

    // Ruta
    ruta_ID,
    descripcionRuta,

    // Proveedor / Almacén / Rubro
    proveedor_ID,
    nombreProveedor,
    almacen_ID,
    nombreAlmacen,
    rubro_ID,
    nombreRubro,

    // Estado y calidad
    estadoViaje,
    esFinalizado,
    esCancelado,
    cumpleRendimientoTeorico,
    esSobrecarga,
    esViajeCorto,
    esViajeLargo,
    eficienciaCategoria,

    // Métricas de distancia y tiempo
    distanciaKm,
    kilometrosRecorridos,
    duracionHoras,

    // Métricas de combustible y costo
    litrosSalida,
    consumoRealTotal,
    consumoTeoricoTotal,
    combustibleTeorico,
    costoTeorico,
    costoPorKm,
    precioCombustible,

    // Rendimiento
    rendimientoReal,
    rendimientoTeorico,
    variacionRendimientoPct,
    kilometrosPorLitro,
    horasPorLitro,

    // Carga
    pesoCarga,
    pesoIda,
    pesoVuelta,
    pesoTotal,
    toneladasPorKm,

    // Telemetría
    velocidadPromedio,
    velocidadMaxima,
    altitudPromedio,
    registrosTelemetria
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

  // Textos descriptivos y value helps sobre dimensiones
  vehiculo_ID @(
    Common.Text: placaVehiculo,
    Common.ValueList: {
      CollectionPath: 'DimensionVehiculo',
      Label: 'Vehículos',
      Parameters: [
        { $Type: 'Common.ValueListParameterOut', LocalDataProperty: vehiculo_ID, ValueListProperty: 'vehiculo_ID' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'placa' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'modelo' }
      ]
    }
  );
  chofer_ID @(
    Common.Text: nombreChofer,
    Common.ValueList: {
      CollectionPath: 'DimensionChofer',
      Label: 'Choferes',
      Parameters: [
        { $Type: 'Common.ValueListParameterOut', LocalDataProperty: chofer_ID, ValueListProperty: 'chofer_ID' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nombreCompleto' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'cedula' }
      ]
    }
  );
  ruta_ID @(
    Common.Text: descripcionRuta,
    Common.ValueList: {
      CollectionPath: 'DimensionRuta',
      Label: 'Rutas',
      Parameters: [
        { $Type: 'Common.ValueListParameterOut', LocalDataProperty: ruta_ID, ValueListProperty: 'ruta_ID' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'descripcion' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'distanciaKm' }
      ]
    }
  );
  proveedor_ID @(
    Common.Text: nombreProveedor,
    Common.ValueList: {
      CollectionPath: 'DimensionProveedor',
      Label: 'Proveedores',
      Parameters: [
        { $Type: 'Common.ValueListParameterOut', LocalDataProperty: proveedor_ID, ValueListProperty: 'proveedor_ID' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nombre' }
      ]
    }
  );
  almacen_ID @(
    Common.Text: nombreAlmacen,
    Common.ValueList: {
      CollectionPath: 'DimensionAlmacen',
      Label: 'Almacenes',
      Parameters: [
        { $Type: 'Common.ValueListParameterOut', LocalDataProperty: almacen_ID, ValueListProperty: 'almacen_ID' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nombreSede' }
      ]
    }
  );
  rubro_ID @Common.Text: nombreRubro;

  // Value helps sobre campos de texto solicitados
  nombreChofer @Common.ValueList: {
    CollectionPath: 'DimensionChofer',
    Label: 'Choferes',
    Parameters: [
      { $Type: 'Common.ValueListParameterOut', LocalDataProperty: nombreChofer, ValueListProperty: 'nombreCompleto' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'cedula' }
    ]
  };
  modeloVehiculo @Common.ValueList: {
    CollectionPath: 'DimensionVehiculo',
    Label: 'Modelos de Vehículo',
    Parameters: [
      { $Type: 'Common.ValueListParameterOut', LocalDataProperty: modeloVehiculo, ValueListProperty: 'modelo' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'placa' }
    ]
  };
  descripcionRuta @Common.ValueList: {
    CollectionPath: 'DimensionRuta',
    Label: 'Rutas',
    Parameters: [
      { $Type: 'Common.ValueListParameterOut', LocalDataProperty: descripcionRuta, ValueListProperty: 'descripcion' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'distanciaKm' }
    ]
  };
  motor_ID @Common.ValueList: {
    CollectionPath: 'Motores',
    Label: 'Motores',
    Parameters: [
      { $Type: 'Common.ValueListParameterOut', LocalDataProperty: motor_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'serie' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'cilindrada' }
    ]
  };
  transmision_ID @Common.ValueList: {
    CollectionPath: 'Transmisiones',
    Label: 'Transmisiones',
    Parameters: [
      { $Type: 'Common.ValueListParameterOut', LocalDataProperty: transmision_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'modeloDiferencial' }
    ]
  };
};

// Proyección dedicada a la app Reportes: filtros con value helps y métricas clave
annotate ReportingService.HechosViajeReportes with @Capabilities: {
  FilterRestrictions: {
    FilterExpressionRestrictions: [
      { Property: fecha, AllowedExpressions: 'SingleRange' }
    ]
  }
};

annotate ReportingService.HechosViajeReportes with @(UI: {
  SelectionFields: [
    // Dimensión tiempo
    fecha,

    // Dimensiones con value help (tienen datos en los hechos)
    placaVehiculo,
    modeloVehiculo,
    nombreChofer,
    descripcionRuta,

    // Estado y calidad
    estadoViaje,

    // Métricas clave
    kilometrosRecorridos,
    litrosSalida,
    consumoRealTotal,
    consumoTeoricoTotal,
    costoTeorico,
    costoPorKm,
    rendimientoReal,
    rendimientoTeorico,
    kilometrosPorLitro,
    pesoCarga,
    pesoIda,
    pesoVuelta
  ]
});

annotate ReportingService.HechosViajeReportes with {
  placaVehiculo @Common.ValueList: {
    CollectionPath: 'DimensionVehiculo',
    Label: 'Placas',
    Parameters: [
      { $Type: 'Common.ValueListParameterOut', LocalDataProperty: placaVehiculo, ValueListProperty: 'placa' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'modelo' }
    ]
  };
  modeloVehiculo @Common.ValueList: {
    CollectionPath: 'DimensionVehiculo',
    Label: 'Modelos de Vehículo',
    Parameters: [
      { $Type: 'Common.ValueListParameterOut', LocalDataProperty: modeloVehiculo, ValueListProperty: 'modelo' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'placa' }
    ]
  };
  nombreChofer @Common.ValueList: {
    CollectionPath: 'DimensionChofer',
    Label: 'Choferes',
    Parameters: [
      { $Type: 'Common.ValueListParameterOut', LocalDataProperty: nombreChofer, ValueListProperty: 'nombreCompleto' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'cedula' }
    ]
  };
  descripcionRuta @Common.ValueList: {
    CollectionPath: 'DimensionRuta',
    Label: 'Rutas',
    Parameters: [
      { $Type: 'Common.ValueListParameterOut', LocalDataProperty: descripcionRuta, ValueListProperty: 'descripcion' },
      { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'distanciaKm' }
    ]
  };
};

// Dimensiones: listas para value help
annotate ReportingService.DimensionVehiculo with @(UI: {
  LineItem: [
    { Value: vehiculo_ID, Label: 'ID' },
    { Value: placa,       Label: 'Placa' },
    { Value: modelo,      Label: 'Modelo' }
  ]
});

annotate ReportingService.DimensionChofer with @(UI: {
  LineItem: [
    { Value: chofer_ID,      Label: 'ID' },
    { Value: nombreCompleto, Label: 'Nombre' },
    { Value: cedula,         Label: 'Cédula' }
  ]
});

annotate ReportingService.DimensionRuta with @(UI: {
  LineItem: [
    { Value: ruta_ID,     Label: 'ID' },
    { Value: descripcion, Label: 'Descripción' },
    { Value: distanciaKm, Label: 'Distancia (km)' }
  ]
});

annotate ReportingService.DimensionProveedor with @(UI: {
  LineItem: [
    { Value: proveedor_ID, Label: 'ID' },
    { Value: nombre,       Label: 'Nombre' }
  ]
});

annotate ReportingService.DimensionAlmacen with @(UI: {
  LineItem: [
    { Value: almacen_ID, Label: 'ID' },
    { Value: nombreSede, Label: 'Sede' }
  ]
});

annotate ReportingService.Motores with @(UI: {
  LineItem: [
    { Value: ID,          Label: 'ID' },
    { Value: serie,       Label: 'Serie' },
    { Value: cilindrada,  Label: 'Cilindrada' },
    { Value: torqueMax,   Label: 'Torque Máx' }
  ]
});

annotate ReportingService.Transmisiones with @(UI: {
  LineItem: [
    { Value: ID,                Label: 'ID' },
    { Value: modeloDiferencial, Label: 'Modelo Diferencial' },
    { Value: relacionTransmision, Label: 'Relación' },
    { Value: tipoEje,           Label: 'Tipo de Eje' }
  ]
});


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
