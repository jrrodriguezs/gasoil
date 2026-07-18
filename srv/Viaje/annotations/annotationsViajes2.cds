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
    estatus                 @readonly: true;
    vehiculoPlaca         @title: 'Placa del vehículo';
    vehiculoModelo        @title: 'Modelo del vehículo';
    distanciaRuta         @title: 'Kilómetros de ruta'            @Measures.Unit: 'km';
    distanciaTotalKm      @title: 'Kilómetros de ruta'                @Measures.Unit: 'km';
    origen                @title: 'Origen del viaje';
    latitudOrigen         @title: 'Latitud de origen';
    longitudOrigen        @title: 'Longitud de origen';
    destino               @title: 'Destino del viaje';
    latitudDestino        @title: 'Latitud de destino';
    longitudDestino       @title: 'Longitud de destino';
    viajesEnRuta          @title: 'Viajes en esta ruta';
    viajesVehiculoEnRuta  @title: 'Viajes de vehículo en ruta';
    consumoUltimo1        @title: 'Consumo viaje -1'              @Measures.Unit: 'l';
    consumoUltimo2        @title: 'Consumo viaje -2'              @Measures.Unit: 'l';
    consumoUltimo3        @title: 'Consumo viaje -3'              @Measures.Unit: 'l';
    consumoPromedioRuta   @title: 'Consumo promedio de la ruta'   @Measures.Unit: 'l';
    consumoUltimoViajeRuta @title: 'Consumo último viaje de la ruta' @Measures.Unit: 'l';
    vehiculoCapacidadTotal @title: 'Capacidad del vehículo'       @Measures.Unit: 'l';
    vehiculoRendimientoBase @title: 'Rendimiento base del vehículo' @Measures.Unit: 'km/l';
    choferCedula          @title: 'Cédula del chofer';
    choferTelefono        @title: 'Teléfono del chofer';
    choferImagen          @title: 'Foto del chofer' @UI.IsImageURL;
    numeroViaje           @title: 'Número de viaje' @readonly: true;
    numeroViajeFormateado @title: 'Número de viaje' @readonly: true;
};


annotate call.Viajes with {
    horaLlegadaReal      @Common.FieldControl : ((estatus = 'Programado' or estatus = 'Finalizado') ? 1 : 3);
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
        Text           : ruta.destino,
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
                    ValueListProperty: 'destino'
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

annotate call.Viajes with @(Capabilities.InsertRestrictions #SubTablaChofer : { Insertable : false });

annotate call.Viajes with @(
    Capabilities.FilterRestrictions: {
        FilterExpressionRestrictions: [
            {
                Property: 'fecha',
                AllowedExpressions: 'SingleRange'
            }
        ]
    },
    UI: {
    SelectionFields  : [
        fecha,
        estatus,
        ruta_ID,
        chofer_ID,
        vehiculo_ID,
        vehiculoPlaca,
        vehiculoModelo
    ],
    HeaderInfo                  : {
        TypeName      : 'Viaje',
        TypeNamePlural: 'Viajes',
        Title         : {Value: nombreRuta},
        Description   : {Value: numeroViajeFormateado}
    },
    
    HeaderFacets                : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'VehiculoPlacaFacet',
            Target: '@UI.DataPoint#vehiculoPlaca',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'VehiculoModeloFacet',
            Target: '@UI.DataPoint#vehiculoModelo',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'VehiculoCapacidadFacet',
            Target: '@UI.DataPoint#vehiculoCapacidadTotal',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'VehiculoRendimientoFacet',
            Target: '@UI.DataPoint#vehiculoRendimientoBase',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'EstadoFacet',
            Target: '@UI.DataPoint#Estado',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'DistanciaTotalFacet',
            Target: '@UI.DataPoint#distanciaTotalKm',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'ViajesEnRutaFacet',
            Target: '@UI.DataPoint#viajesEnRuta',
        },
    ],

    DataPoint #distanciaRuta    : {
        $Type      : 'UI.DataPointType',
        Value      : distanciaRuta,
        Criticality: #Information,
        Title      : 'Kilómetros de ruta'
    },
    DataPoint #distanciaTotalKm : {
        $Type      : 'UI.DataPointType',
        Value      : distanciaTotalKm,
        Criticality: #Information,
        Title      : 'Km de ruta'
    },
    DataPoint #vehiculoCapacidadTotal: {
        $Type      : 'UI.DataPointType',
        Value      : vehiculoCapacidadTotal,
        Criticality: #Information,
        Title      : 'Capacidad vehículo'
    },
    DataPoint #vehiculoRendimientoBase: {
        $Type      : 'UI.DataPointType',
        Value      : vehiculoRendimientoBase,
        Criticality: #Information,
        Title      : 'Rendimiento base'
    },
    DataPoint #choferCedula     : {
        $Type      : 'UI.DataPointType',
        Value      : choferCedula,
        Criticality: #Information,
        Title      : 'Cédula chofer'
    },
    DataPoint #choferTelefono   : {
        $Type      : 'UI.DataPointType',
        Value      : choferTelefono,
        Criticality: #Information,
        Title      : 'Teléfono chofer'
    },
    DataPoint #combustibleTeorico: {
        $Type      : 'UI.DataPointType',
        Value      : combustibleTeorico,
        Criticality: #Information,
        Title      : 'Combustible necesario'
    },
    DataPoint #vehiculoPlaca    : {
        $Type      : 'UI.DataPointType',
        Value      : vehiculoPlaca,
        Criticality: #Information,
        Title      : 'Placa del vehículo'
    },
    DataPoint #vehiculoModelo   : {
        $Type      : 'UI.DataPointType',
        Value      : vehiculoModelo,
        Criticality: #Information,
        Title      : 'Modelo del vehículo'
    },
    DataPoint #viajesEnRuta     : {
        $Type      : 'UI.DataPointType',
        Value      : viajesEnRuta,
        Criticality: #Information,
        Title      : 'Viajes en esta ruta'
    },
    DataPoint #viajesVehiculoEnRuta : {
        $Type      : 'UI.DataPointType',
        Value      : viajesVehiculoEnRuta,
        Criticality: #Information,
        Title      : 'Viajes de vehículo en ruta'
    },
    DataPoint #consumoUltimo1   : {
        $Type      : 'UI.DataPointType',
        Value      : consumoUltimo1,
        Criticality: #Information,
        Title      : 'Consumo último viaje'
    },
    DataPoint #consumoUltimo2   : {
        $Type      : 'UI.DataPointType',
        Value      : consumoUltimo2,
        Criticality: #Information,
        Title      : 'Consumo 2do último viaje'
    },
    DataPoint #consumoUltimo3   : {
        $Type      : 'UI.DataPointType',
        Value      : consumoUltimo3,
        Criticality: #Information,
        Title      : 'Consumo 3er último viaje'
    },
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
    DataPoint #costo            : {
        $Type      : 'UI.DataPointType',
        Value      : costoTeorico,
        Criticality: #Information,
        Title      : 'Costo'
    },

    LineItem                    : [
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'ConfigService.changeStatus',
            Label : 'Empezar viaje',
        },
        {
            Value: numeroViajeFormateado,
            Label: 'Número de viaje'
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
            Value: ruta.destino,
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
    LineItem #SubTablaChofer    : [
        { Value: fecha, Label: 'Fecha' },
        { Value: ruta.destino, Label: 'Ruta' },
        { Value: choferNombreCompleto, Label: 'Chofer' },
        { Value: estatus, Label: 'Estatus' },
        { Value: horaSalida, Label: 'Hora salida' },
        { Value: horaLlegada, Label: 'Hora llegada estimada' },
        { Value: horaLlegadaReal, Label: 'Hora llegada real' },
        { Value: litrosSalida, Label: 'Litros viaje' },
        { Value: pesoCarga, Label: 'Peso carga' }
    ],
    Identification              : [
        { Value: nombreRuta, Label: 'Ruta' },
        { Value: numeroViaje, Label: 'Número de viaje' },
        { Value: fecha, Label: 'Fecha' },
        { Value: ruta_ID, Label: 'Ruta' },
        { Value: vehiculo_ID, Label: 'Vehiculo' },
        { Value: chofer_ID, Label: 'Chofer' },
        { Value: proveedor_ID, Label: 'Proveedor' },
        { Value: estatus, Label: 'Estatus' },
        { Value: horaSalida, Label: 'Hora salida' },
        { Value: horaLlegada, Label: 'Hora llegada estimada' },
        { Value: horaLlegadaReal, Label: 'Hora llegada real' },
        { Value: litrosSalida, Label: 'Litros viaje' },
        { Value: pesoCarga, Label: 'Peso carga' },
        { Value: rubro_ID, Label: 'Rubro' },
        { Value: pesoIda, Label: 'Peso ida' },
        { Value: pesoVuelta, Label: 'Peso vuelta' },
        { Value: origen, Label: 'Origen' },
        { Value: latitudOrigen, Label: 'Latitud origen' },
        { Value: longitudOrigen, Label: 'Longitud origen' }
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
    FieldGroup #OrigenViaje     : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: origen,
            },
            {
                $Type: 'UI.DataField',
                Value: latitudOrigen,
            },
            {
                $Type: 'UI.DataField',
                Value: longitudOrigen,
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
            {
                $Type : 'UI.ReferenceFacet',
                Target: '@UI.FieldGroup#OrigenViaje',
                Label : 'Origen del viaje',
            },
        ],
    }, ],
});
