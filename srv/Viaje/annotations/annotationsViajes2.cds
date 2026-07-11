using {ConfigService as call} from '../../service';

annotate call.Viajes with {
    fecha                 @title: 'Fecha del viaje';
    ruta                  @title: 'Ruta del viaje';
    choferNombreCompleto  @title: 'Chofer del viaje';
    chofer                @title: 'Chofer';
    vehiculo              @title: 'Vehículo';
    horaSalida            @title: 'Hora de salida';
    horaLlegada           @title: 'Hora de llegada estimada';
    horaLlegadaReal       @title: 'Hora de llegada real';
    litrosSalida          @title: 'Litros consumidos en el viaje'  @Measures.Unit: 'l';
    kilometrosRecorridos  @title: 'Kilómetros recorridos'          @Measures.Unit: 'km';
    pesoCarga             @title: 'Peso de la carga';
    rubro                 @title: 'Rubro del viaje';
    estatus               @title: 'Estatus del viaje';
    pesoIda               @title: 'Peso de ida';
    pesoVuelta            @title: 'Peso de vuelta';
    rendimientoTeorico    @title: 'Rendimiento teórico'           @Measures.Unit: 'km/l';
    combustibleTeorico    @title: 'Combustible teórico'           @Measures.Unit: 'l';

};


annotate call.Viajes with {
    horaLlegadaReal      @Common.FieldControl : (estatus = 'Programado' ? 1 : 3 or estatus = 'Finalizado' ? 1 : 3);
    pesoVuelta           @Common.FieldControl : (estatus = 'Programado' ? 1 : 3);
    litrosSalida         @Common.FieldControl : (estatus = 'Programado' ? 1 : 3);
    kilometrosRecorridos @Common.FieldControl : (estatus = 'Programado' ? 1 : 3);
};


annotate call.Viajes with {
    estatus  @(Common: {
        Text           : estatusRef.descr,
        TextArrangement: #TextOnly,
        ValueList      : {
            CollectionPath: 'EstadoViajes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    LocalDataProperty: estatus,
                    ValueListProperty: 'code'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        },
        ValueListWithFixedValues : true,
    });
    vehiculo @(Common: {
        Text           : vehiculo.placa,
        TextArrangement: #TextOnly,
        ValueList      : {
            CollectionPath: 'Vehiculos',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    LocalDataProperty: vehiculo_ID,
                    ValueListProperty: 'ID'
                },
                {
                    $Type            : 'Common.ValueListParameterConstant',
                    ValueListProperty: 'estadodelvehiculo_code',
                    Constant         : 'Operativo'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'placa'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'modelo'
                }
            ]
        }
    });

    ruta     @(Common: {
        Text           : ruta.descripcion,
        TextArrangement: #TextOnly,
        ValueList      : {
            CollectionPath              : 'Rutas',
            PresentationVariantQualifier: 'RutaVH',
            Parameters                  : [
                {
                    $Type            : 'Common.ValueListParameterIn',
                    LocalDataProperty: ruta_ID,
                    ValueListProperty: 'ID'
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: ruta_ID,
                    ValueListProperty: 'ID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'descripcion'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'distanciaKm'
                }
            ]
        }
    });

    chofer   @(Common: {
        Text           : chofer.nombreCompleto,
        TextArrangement: #TextOnly,
        ValueList      : {
            CollectionPath: 'Choferes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    LocalDataProperty: chofer_ID,
                    ValueListProperty: 'ID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'nombreCompleto'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'cedula'
                }
            ]
        }
    });
    rubro    @(Common: {
        Text           : rubro.name,
        TextArrangement: #TextOnly,
        ValueList      : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'Rubros',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    LocalDataProperty: rubro_ID,
                    ValueListProperty: 'ID',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'description',
                },
            ],
        },
    }

    )
};

annotate call.Viajes with @(
    Common.SideEffects: {
        $Type : 'Common.SideEffectsType',
        SourceProperties : [
          pesoCarga,
          proveedor_ID,
          vehiculo_ID,
          ruta_ID,
          chofer_ID,
          pesoIda,
          pesoVuelta
      ],
      SourceEntities : [
          vehiculo,
          ruta,
          chofer
      ],
      TargetProperties : [
          'rendimientoTeorico',
          'combustibleTeorico',
          'costoTeorico'
      ],
    }
);

annotate call.Viajes with @(UI: {

   
    SelectionFields  : [
        estatus
    ],
    HeaderInfo                  : {
        TypeName      : 'Viaje',
        TypeNamePlural: 'Viajes',
        Title         : {Value: ruta.descripcion},
        Description   : {Value: fecha}
    },
    
    HeaderFacets                : [
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.DataPoint#rendimiento',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.DataPoint#combustible',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.DataPoint#Estado',
        },

    ],

    DataPoint #rendimiento      : {
        $Type      : 'UI.DataPointType',
        Value      : rendimientoTeorico,
        Criticality: #Information,
        Title      : 'Rendimiento'
    },
    DataPoint #combustible      : {
        $Type      : 'UI.DataPointType',
        Value      : litrosSalida,
        Criticality: #Information,
        Title      : 'Combustible'
    },
    DataPoint #Estado           : {
        $Type      : 'UI.DataPointType',
        Value      : estatus,
        Criticality: #Information,
        Title      : 'Estado del viaje'
    },

    LineItem                    : [
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'ConfigService.changeStatus',
            Label : 'Empezar viaje',
        },
        {
            Value: fecha,
            Label: 'Fecha'
        },
        {
            $Type : 'UI.DataField',
            Value : estatus,
            Label : 'Estatus del viaje'
        },
        {
            Value: ruta.descripcion,
            Label: 'Ruta'
        },
        {
            Value: choferNombreCompleto,
            Label: 'Chofer'
        },
        {
            Value: horaSalida,
            Label: 'Hora salida'
        },
        {
            Value: horaLlegada,
            Label: 'Hora llegada estimada'
        },
        {
            Value: horaLlegadaReal,
            Label: 'Hora llegada real'
        },
        {
            Value: litrosSalida,
            Label: 'Litros viaje'
        },
        {
            Value: pesoCarga,
            Label: 'Peso carga'
        }
    ],
    FieldGroup #DatosIniciales  : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: ruta_ID,
            },
            {
                $Type: 'UI.DataField',
                Value: chofer_ID,
            },
            {
                $Type: 'UI.DataField',
                Value: vehiculo_ID,
            },
        ]
    },

    FieldGroup #FechaViaje      : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: horaSalida,
            },
            {
                $Type: 'UI.DataField',
                Value: horaLlegada,
            },
            {
                $Type: 'UI.DataField',
                Value: horaLlegadaReal,
            }
        ]
    },

    FieldGroup #DatosPesoConsumo: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: rubro_ID,
            },
            {
                $Type: 'UI.DataField',
                Value: pesoIda,
            },
            {
                $Type: 'UI.DataField',
                Value: kilometrosRecorridos
            },
            {
                $Type: 'UI.DataField',
                Value: litrosSalida,
            },
            {
                $Type: 'UI.DataField',
                Value: pesoVuelta,
            }
        ]
    },
    Facets                      : [{
        $Type : 'UI.CollectionFacet',
        Label : 'Orden de Trabajo',
        ID    : 'InfoViajeFacet',
        Facets: [
            {
                $Type : 'UI.ReferenceFacet',
                Target: '@UI.FieldGroup#DatosIniciales',
                Label : 'Datos de la ruta',
            },
            {
                $Type : 'UI.ReferenceFacet',
                Target: '@UI.FieldGroup#FechaViaje',
                Label : 'Fecha del viaje',
            },
            {
                $Type : 'UI.ReferenceFacet',
                Target: '@UI.FieldGroup#DatosPesoConsumo',
                Label : 'Datos de peso y consumo',
            },
        ],
    }, ],
});
