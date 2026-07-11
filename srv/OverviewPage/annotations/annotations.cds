using { ConfigService } from '../service/service';
annotate ConfigService.PerformacePerVehicle with @UI: {
  LineItem #Overview: [
    {
      $Type: 'UI.DataField',
      Value: placa,
      Label: 'Vehiculo'
    },
    {
      $Type: 'UI.DataField',
      Value: modelo,
      Label: 'Modelo'
    },
    {
      $Type: 'UI.DataFieldForAnnotation',
      Target: '@UI.DataPoint#Rendimiento',
      Label: 'Rendimiento'
    }
  ],
  DataPoint #Rendimiento: {
    $Type: 'UI.DataPointType',
    Title: 'Rendimiento',
    Value: promedioKm,
    ValueFormat : {
        $Type : 'UI.NumberFormat',
        NumberOfFractionalDigits : 2,
    },
  },
  PresentationVariant #Overview: {
    SortOrder: [
      {
        Property: promedioKm,
        Descending: true
      }
    ],
    Visualizations: ['@UI.LineItem#Overview']
  },
  PresentationVariant#OverviewAscending: {
      $Type : 'UI.PresentationVariantType',
      SortOrder : [
          {
              Property : promedioKm,
              Descending : false
          }
      ],
      Visualizations: ['@UI.LineItem#Overview']
  },
};

annotate ConfigService.PerformanceAvg with @UI: {
  DataPoint #AvgRendimiento: {
    $Type: 'UI.DataPointType',
    Title: 'Promedio de rendimiento',
    Value: rendimientoPromedioGeneral,
    Unit: measure
  },
  Identification #KPI: [
    {
      $Type: 'UI.DataField',
      Value: totalVehiculos,
      Label: 'Vehiculos considerados'
    }
  ],
  PresentationVariant #KPI: {
    Visualizations: ['@UI.DataPoint#AvgRendimiento']
  },
  KPI #AvgRendimiento: {
    $Type: 'UI.KPIType',
    ID: 'AvgRendimiento',
    DataPoint: ![@UI.DataPoint#AvgRendimiento],
    Detail: {
      $Type: 'UI.KPIDetailType',
      DefaultPresentationVariant: ![@UI.PresentationVariant#KPI]
    }
  }
};

annotate ConfigService.PerformanceByModel with {
  rendimientoPromedio @Measures.Unit: 'km/L'
}

annotate ConfigService.PerformanceByModel with @UI: {
  LineItem #ByModel: [
    {
      $Type: 'UI.DataField',
      Value: modelo,
      Label: 'Modelo'
    },
    {
      $Type: 'UI.DataFieldForAnnotation',
      Target: '@UI.DataPoint#RendimientoModelo',
      Label: 'Rendimiento Promedio'
    }
  ],
  DataPoint #RendimientoModelo: {
    $Type: 'UI.DataPointType',
    Title: 'Rendimiento Promedio',
    Value: rendimientoPromedio,
    Unit: measure,
    ValueFormat : {
        $Type : 'UI.NumberFormat',
        NumberOfFractionalDigits : 2,
    },
  },
  PresentationVariant #ByModel: {
    SortOrder: [
      {
        Property: rendimientoPromedio,
        Descending: true
      }
    ],
    Visualizations: ['@UI.LineItem#ByModel']
  },
  PresentationVariant#ByModelAscending : {
      $Type : 'UI.PresentationVariantType',
      SortOrder : [
          {
              Property : rendimientoPromedio,
              Descending : false
          }
      ],
      Visualizations: ['@UI.LineItem#ByModel']
  },
};

annotate ConfigService.TankCapacity with @(
  UI.LineItem#PorcentajeLineItem: [
    {
        $Type : 'UI.DataField',
        Value : descripcion,
        Label : 'Tanque'
    },
    {
        $Type : 'UI.DataField',
        Value : nivelActual,
        Label : 'Nivel de Combustible'
    },
    {
        $Type : 'UI.DataFieldForAnnotation',
        Target : '@UI.DataPoint#PorcentajeLlenado',
    },
  ],

  UI.DataPoint#PorcentajeLlenado : {
    $Type : 'UI.DataPointType',
    Title : 'Porcentaje de llenado',
    Value : porcentajeLlenado,
    Criticality: criticality
  },
){
  porcentajeLlenado @Measures.Unit: '%'
};

annotate ConfigService.PerformancePerRoute with @(
  UI.LineItem#PerformancePerRoute : [
      {
          $Type : 'UI.DataField',
          Value : ruta,
          Label : 'Ruta'
      },
      {
          $Type : 'UI.DataFieldForAnnotation',
          Target : '@UI.DataPoint#Rendimiento',
          Label : 'Rendimiento',
      },
  ],
  UI.DataPoint #Rendimiento : {
    $Type : 'UI.DataPointType',
    Title : 'Rendimiento Promedio',
    Value : rendimientoPromedio,
    ValueFormat : {
        $Type : 'UI.NumberFormat',
        NumberOfFractionalDigits : 2
    }
  },
  UI.PresentationVariant#Ascending : {
      SortOrder : [
          {
              Property : rendimientoPromedio,
              Descending : false
          }
      ],
      Visualizations : ['@UI.LineItem#PerformancePerRoute']
  },
  UI.PresentationVariant#Descending : {
      SortOrder : [
          {
              Property : rendimientoPromedio,
              Descending : true
          }
      ],
      Visualizations : ['@UI.LineItem#PerformancePerRoute']
  }
){
  rendimientoPromedio @Measures.Unit: 'km/L'
};

annotate ConfigService.VehiclePerStatus with {
  cantidad @Analytics.Measure: true @Aggregation.default: #SUM;
};

annotate ConfigService.VehiclePerStatus with @UI: {
  DataPoint #CantidadVehiculos: {
    $Type: 'UI.DataPointType',
    Title: 'Cantidad de vehiculos',
    Value: cantidad
  },
  Chart #EstadoVehiculoDonut: {
    $Type: 'UI.ChartDefinitionType',
    Title: 'Vehiculos por estado',
    ChartType: #Donut,
    Dimensions: [estado],
    DimensionAttributes: [
      {
        $Type: 'UI.ChartDimensionAttributeType',
        Dimension: estado,
        Role: #Category
      }
    ],
    Measures: [cantidad],
    MeasureAttributes: [
      {
        $Type: 'UI.ChartMeasureAttributeType',
        Measure: cantidad,
        Role: #Axis1,
        DataPoint: '@UI.DataPoint#CantidadVehiculos'
      }
    ]
  },
  PresentationVariant #EstadoVehiculoDonut: {
    SortOrder: [
      {
        Property: cantidad,
        Descending: true
      }
    ],
    Visualizations: ['@UI.Chart#EstadoVehiculoDonut']
  }
};

annotate ConfigService.TankPerStatus with {
  cantidad @Analytics.Measure: true @Aggregation.default: #SUM;
};

annotate ConfigService.TankPerStatus with @UI: {
  DataPoint #CantidadTanques: {
    $Type: 'UI.DataPointType',
    Title: 'Cantidad de tanques',
    Value: cantidad
  },
  Chart #EstadoTanqueDonut: {
    $Type: 'UI.ChartDefinitionType',
    Title: 'Tanques por estado',
    ChartType: #Donut,
    Dimensions: [status],
    DimensionAttributes: [
      {
        $Type: 'UI.ChartDimensionAttributeType',
        Dimension: status,
        Role: #Category
      }
    ],
    Measures: [cantidad],
    MeasureAttributes: [
      {
        $Type: 'UI.ChartMeasureAttributeType',
        Measure: cantidad,
        Role: #Axis1,
        DataPoint: '@UI.DataPoint#CantidadTanques'
      }
    ]
  },
  PresentationVariant #EstadoTanqueDonut: {
    SortOrder: [
      {
        Property: cantidad,
        Descending: true
      }
    ],
    Visualizations: ['@UI.Chart#EstadoTanqueDonut']
  }
};

annotate ConfigService.PerformacePerMotor with @(
  UI.LineItem#PerformancePerComponents: [
    {
        $Type : 'UI.DataField',
        Value : modeloMotor,
        Label : 'Motor'
    },
    {
        $Type : 'UI.DataFieldForAnnotation',
        Target : '@UI.DataPoint#Rendimiento',
        Label : 'Rendimiento',
    },
    {
        $Type : 'UI.DataFieldForAnnotation',
        Target : '@UI.DataPoint#RendimientoMaximo',
        Label : 'Rendimiento Máximo',
    },
  ],
  UI.DataPoint #Rendimiento : {
    $Type : 'UI.DataPointType',
    Title : 'Unit Price',
    Value : rendimiento,
    ValueFormat : {
        $Type : 'UI.NumberFormat',
        ScaleFactor : 1,
        NumberOfFractionalDigits : 2
    }
},
  UI.DataPoint #RendimientoMaximo : {
    $Type : 'UI.DataPointType',
    Title : 'Unit Price',
    Value : rendimientoMaximo,
    ValueFormat : {
        $Type : 'UI.NumberFormat',
        ScaleFactor : 1,
        NumberOfFractionalDigits : 2
    }
},
  UI.PresentationVariant#Ascending : {
      SortOrder : [
          {
              Property : rendimiento,
              Descending : false
          }
      ],
      Visualizations : ['@UI.LineItem#PerformancePerComponents']
  },
  UI.PresentationVariant#Descending : {
      SortOrder : [
          {
              Property : rendimiento,
              Descending : true
          }
      ],
      Visualizations : ['@UI.LineItem#PerformancePerComponents']
  }
){
  rendimiento @Measures.Unit: 'km/L';
  rendimientoMaximo @Measures.Unit: 'km/L'
}

annotate ConfigService.PerformacePerTransmision with @(
  UI.LineItem#PerformancePerComponents: [
    {
        $Type : 'UI.DataField',
        Value : modeloDiferencial,
        Label : 'Transmision'
    },
    {
        $Type : 'UI.DataFieldForAnnotation',
        Target : '@UI.DataPoint#Rendimiento',
        Label : 'Rendimiento',
    },
    {
        $Type : 'UI.DataFieldForAnnotation',
        Target : '@UI.DataPoint#RendimientoMaximo',
        Label : 'Rendimiento Máximo',
    },
  ],
  UI.DataPoint #Rendimiento : {
    $Type : 'UI.DataPointType',
    Title : 'Unit Price',
    Value : rendimiento,
    ValueFormat : {
        $Type : 'UI.NumberFormat',
        ScaleFactor : 1,
        NumberOfFractionalDigits : 2
    }
},
  UI.DataPoint #RendimientoMaximo : {
    $Type : 'UI.DataPointType',
    Title : 'Unit Price',
    Value : rendimientoMaximo,
    ValueFormat : {
        $Type : 'UI.NumberFormat',
        ScaleFactor : 1,
        NumberOfFractionalDigits : 2
    }
},
  UI.PresentationVariant#Ascending : {
      SortOrder : [
          {
              Property : rendimiento,
              Descending : false
          }
      ],
      Visualizations : ['@UI.LineItem#PerformancePerComponents']
  },
  UI.PresentationVariant#Descending : {
      SortOrder : [
          {
              Property : rendimiento,
              Descending : true
          }
      ],
      Visualizations : ['@UI.LineItem#PerformancePerComponents']
  }
){
  rendimiento @Measures.Unit: 'km/L';
  rendimientoMaximo @Measures.Unit: 'km/L'
}

annotate ConfigService.PerformacePerCaja with @(
  UI.LineItem#PerformancePerComponents: [
    {
        $Type : 'UI.DataField',
        Value : modeloCaja,
        Label : 'Caja'
    },
    {
        $Type : 'UI.DataFieldForAnnotation',
        Target : '@UI.DataPoint#Rendimiento',
        Label : 'Rendimiento',
    },
    {
        $Type : 'UI.DataFieldForAnnotation',
        Target : '@UI.DataPoint#RendimientoMaximo',
        Label : 'Rendimiento Máximo',
    },
  ],
  UI.DataPoint #Rendimiento : {
    $Type : 'UI.DataPointType',
    Title : 'Unit Price',
    Value : rendimiento,
    ValueFormat : {
        $Type : 'UI.NumberFormat',
        ScaleFactor : 1,
        NumberOfFractionalDigits : 2
    }
},
  UI.DataPoint #RendimientoMaximo : {
    $Type : 'UI.DataPointType',
    Title : 'Unit Price',
    Value : rendimientoMaximo,
    ValueFormat : {
        $Type : 'UI.NumberFormat',
        ScaleFactor : 1,
        NumberOfFractionalDigits : 2
    }
},
  UI.PresentationVariant#Ascending : {
      SortOrder : [
          {
              Property : rendimiento,
              Descending : false
          }
      ],
      Visualizations : ['@UI.LineItem#PerformancePerComponents']
  },
  UI.PresentationVariant#Descending : {
      SortOrder : [
          {
              Property : rendimiento,
              Descending : true
          }
      ],
      Visualizations : ['@UI.LineItem#PerformancePerComponents']
  }
){
  rendimiento @Measures.Unit: 'km/L';
  rendimientoMaximo @Measures.Unit: 'km/L'
}

annotate ConfigService.PerformancePerRubro with @(
  UI.LineItem#PerformancePerRubro: [
    {
        $Type : 'UI.DataField',
        Value : rubro,
        Label : 'Rubro'
    },
    {
        $Type : 'UI.DataField',
        Value : cantidad,
        Label : 'Cantidad de viajes'
    },
    {
        $Type : 'UI.DataFieldForAnnotation',
        Target : '@UI.DataPoint#Rendimiento',
        Label : 'Rendimiento Promedio',
    },
    {
        $Type : 'UI.DataFieldForAnnotation',
        Target : '@UI.DataPoint#RendimientoMaximo',
        Label : 'Rendimiento Máximo',
    },
  ],
  UI.DataPoint #Rendimiento : {
    $Type : 'UI.DataPointType',
    Title : 'Unit Price',
    Value : rendimiento,
    ValueFormat : {
        $Type : 'UI.NumberFormat',
        ScaleFactor : 1,
        NumberOfFractionalDigits : 2
    }
},
  UI.DataPoint #RendimientoMaximo : {
    $Type : 'UI.DataPointType',
    Title : 'Unit Price',
    Value : rendimientoMaximo,
    ValueFormat : {
        $Type : 'UI.NumberFormat',
        ScaleFactor : 1,
        NumberOfFractionalDigits : 2
    }
},
  UI.PresentationVariant#Ascending : {
      SortOrder : [
          {
              Property : rendimiento,
              Descending : false
          }
      ],
      Visualizations : ['@UI.LineItem#PerformancePerRubro']
  },
  UI.PresentationVariant#Descending : {
      SortOrder : [
          {
              Property : rendimiento,
              Descending : true
          }
      ],
      Visualizations : ['@UI.LineItem#PerformancePerRubro']
  }
){
  rendimiento @Measures.Unit: 'km/L';
  rendimientoMaximo @Measures.Unit: 'km/L'
};

annotate ConfigService.ViajesPorRutaSum with{
  @Measures.Unit : unitViajes
  cantidadViajes @title : 'Cantidad de Viajes';
  @Measures.Unit : unitKm
  distanciaRecorrida @title : 'Kilómetros Recorridos';
  ruta @title : 'Ruta'; 
}
annotate ConfigService.ViajesPorRutaSum with @(
  UI.Chart #ViajesTotal       : {
        $Type              : 'UI.ChartDefinitionType',
        ChartType          : #Column,
        Description        : 'Chart',
        Measures           : [ cantidadViajes],
        MeasureAttributes  : [{
            $Type  : 'UI.ChartMeasureAttributeType',
            Measure: cantidadViajes,
            Role   : #Axis1,
        }, ],
        Dimensions         : [
            ruta,
        ],
        DimensionAttributes: [
            {
                $Type    : 'UI.ChartDimensionAttributeType',
                Dimension: ruta,
                Role     : #Category,
            },
        ],
    },
    UI.PresentationVariant #ViajesTotal: {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart#ViajesTotal'],
        SortOrder     : [{
            $Type   : 'Common.SortOrderType',
            Property: cantidadViajes,
            Descending: true,
        }, ],
        MaxItems: 3
    },


    UI.Chart #KmTotal       : {
        $Type              : 'UI.ChartDefinitionType',
        ChartType          : #Column,
        Description        : 'Chart',
        Measures           : [ distanciaRecorrida ],
        MeasureAttributes  : [{
            $Type  : 'UI.ChartMeasureAttributeType',
            Measure: distanciaRecorrida,
            Role   : #Axis1,
        }, ],
        Dimensions         : [
            ruta,
        ],
        DimensionAttributes: [
            {
                $Type    : 'UI.ChartDimensionAttributeType',
                Dimension: ruta,
                Role     : #Category,
            },
        ],
    },
    UI.PresentationVariant #KmTotal: {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart#KmTotal'],
        SortOrder     : [{
            $Type   : 'Common.SortOrderType',
            Property: distanciaRecorrida,
            Descending: true
        }, ],
        MaxItems: 3

    },
    UI.SelectionVariant#ViajesTotal: { $Type : 'UI.SelectionVariantType', },
    UI.SelectionVariant#KmTotal: { $Type : 'UI.SelectionVariantType' },
    UI.Identification #ViajesTotal:[],
    UI.Identification #KmTotal:[],
    UI.DataPoint #ViajesTotal: {$Type : 'UI.DataPointType',},
    UI.DataPoint #KmTotal: {$Type : 'UI.DataPointType',},

);

annotate ConfigService.ViajesPorMes with @(
  UI.Chart #ViajesMes       : {
        $Type              : 'UI.ChartDefinitionType',
        ChartType          : #Column,
        Description        : 'Chart',
        Measures           : [ cantidadViajes ],
        MeasureAttributes  : [{
            $Type  : 'UI.ChartMeasureAttributeType',
            Measure: cantidadViajes,
            Role   : #Axis1,
        }, ],
        Dimensions         : [
            fechaText
        ],
        DimensionAttributes: [
            {
                $Type    : 'UI.ChartDimensionAttributeType',
                Dimension: fechaText,
                Role     : #Category2,
            },
        ],
    },
    UI.PresentationVariant #ViajesMes: {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart#ViajesMes'],
        MaxItems: 3

    },


    UI.Chart #KmMes       : {
        $Type              : 'UI.ChartDefinitionType',
        ChartType          : #Column,
        Description        : 'Chart',
        Measures           : [ distanciaRecorrida ],
        MeasureAttributes  : [{
            $Type  : 'UI.ChartMeasureAttributeType',
            Measure: distanciaRecorrida,
            Role   : #Axis1,
        }, ],
        Dimensions         : [
            fechaText
        ],
        DimensionAttributes: [
            {
                $Type    : 'UI.ChartDimensionAttributeType',
                Dimension: fechaText,
                Role     : #Category,
            },
        ],
    },
    UI.PresentationVariant #KmMes: {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart#KmMes'],
        MaxItems: 3

    },
    UI.SelectionVariant#ViajesMes: { $Type : 'UI.SelectionVariantType', },
    UI.SelectionVariant#KmMes: { $Type : 'UI.SelectionVariantType' },
    UI.Identification #ViajesMes:[],
    UI.Identification #KmMes:[],
    UI.DataPoint #ViajesMes: {$Type : 'UI.DataPointType',},
    UI.DataPoint #KmMes: {$Type : 'UI.DataPointType',},
){
  @Measures.Unit : unitViajes
  cantidadViajes @title : 'Cantidad de Viajes';
  @Measures.Unit : unitKm
  distanciaRecorrida @title : 'Kilómetros Recorridos';
  fechaText @title : 'Mes';
};

annotate ConfigService.ViajesPorAnio with @(
  UI.Chart #ViajesAnio       : {
        $Type              : 'UI.ChartDefinitionType',
        ChartType          : #Column,
        Description        : 'Chart',
        Measures           : [ cantidadViajes ],
        MeasureAttributes  : [{
            $Type  : 'UI.ChartMeasureAttributeType',
            Measure: cantidadViajes,
            Role   : #Axis1,
        }, ],
        Dimensions         : [
            anio
        ],
        DimensionAttributes: [
            {
                $Type    : 'UI.ChartDimensionAttributeType',
                Dimension: anio,
                Role     : #Category2,
            },
        ],
    },
    UI.PresentationVariant #ViajesAnio: {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart#ViajesAnio'],
        MaxItems: 3

    },


    UI.Chart #KmAnio       : {
        $Type              : 'UI.ChartDefinitionType',
        ChartType          : #Column,
        Description        : 'Chart',
        Measures           : [ distanciaRecorrida ],
        MeasureAttributes  : [{
            $Type  : 'UI.ChartMeasureAttributeType',
            Measure: distanciaRecorrida,
            Role   : #Axis1,
        }, ],
        Dimensions         : [
            anio
        ],
        DimensionAttributes: [
            {
                $Type    : 'UI.ChartDimensionAttributeType',
                Dimension: anio,
                Role     : #Category2,
            },
        ],
    },
    UI.PresentationVariant #KmAnio: {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart#KmAnio'],
        MaxItems: 3

    },
    UI.SelectionVariant#ViajesAnio: { $Type : 'UI.SelectionVariantType', },
    UI.SelectionVariant#KmAnio: { $Type : 'UI.SelectionVariantType' },
    UI.Identification #ViajesAnio:[],
    UI.Identification #KmAnio:[],
    UI.DataPoint #ViajesAnio: {$Type : 'UI.DataPointType',},
    UI.DataPoint #KmAnio: {$Type : 'UI.DataPointType',},

){
  @Measures.Unit : unitViajes
  cantidadViajes @title : 'Cantidad de Viajes';
  @Measures.Unit : unitKm
  distanciaRecorrida @title : 'Kilómetros Recorridos';
  anio @title : 'Año';
};

annotate ConfigService.ViajesPorTrimestre with @(
  UI.Chart #ViajesTrimestre       : {
        $Type              : 'UI.ChartDefinitionType',
        ChartType          : #Column,
        Description        : 'Chart',
        Measures           : [ cantidadViajes ],
        MeasureAttributes  : [{
            $Type  : 'UI.ChartMeasureAttributeType',
            Measure: cantidadViajes,
            Role   : #Axis1,
        }, ],
        Dimensions         : [
            fechaText
        ],
        DimensionAttributes: [
            {
                $Type    : 'UI.ChartDimensionAttributeType',
                Dimension: fechaText,
                Role     : #Series,
            },
        ],
    },
    UI.PresentationVariant #ViajesTrimestre: {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart#ViajesTrimestre'],
        MaxItems: 3

    },


    UI.Chart #KmTrimestre       : {
        $Type              : 'UI.ChartDefinitionType',
        ChartType          : #Column,
        Description        : 'Chart',
        Measures           : [ distanciaRecorrida ],
        MeasureAttributes  : [{
            $Type  : 'UI.ChartMeasureAttributeType',
            Measure: distanciaRecorrida,
            Role   : #Axis1,
        }, ],
        Dimensions         : [
            fechaText
        ],
        DimensionAttributes: [
            {
                $Type    : 'UI.ChartDimensionAttributeType',
                Dimension: fechaText,
                Role     : #Category2,
            },
        ],
    },
    UI.PresentationVariant #KmTrimestre: {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart#KmTrimestre'],
        MaxItems: 3

    },
    UI.SelectionVariant#ViajesTrimestre: { $Type : 'UI.SelectionVariantType', },
    UI.SelectionVariant#KmTrimestre: { $Type : 'UI.SelectionVariantType' },
    UI.Identification #ViajesTrimestre:[],
    UI.Identification #KmTrimestre:[],
    UI.DataPoint #ViajesTrimestre: {$Type : 'UI.DataPointType',},
    UI.DataPoint #KmTrimestre: {$Type : 'UI.DataPointType',},
){
  @Measures.Unit : unitViajes
  cantidadViajes @title : 'Cantidad de Viajes';
  @Measures.Unit : unitKm
  distanciaRecorrida @title : 'Kilómetros Recorridos';
  fechaText @title : 'Trimestre';
};