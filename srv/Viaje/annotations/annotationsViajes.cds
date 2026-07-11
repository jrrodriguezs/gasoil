using { ConfigService } from '../../service';


annotate ConfigService.Viajes with {
  estatus @readonly : true;
};



annotate ConfigService.Viajes with @(
  odata.draft.enabled,
  Capabilities : {
    InsertRestrictions : { Insertable : true },
    UpdateRestrictions : { Updatable : true },
    DeleteRestrictions : { Deletable : true }
  },
  UI : {
    HeaderInfo : {
      TypeName : 'Viaje',
      TypeNamePlural : 'Viajes',
      Title : { Value : ruta.descripcion },
      Description : { Value : fecha }
    },
    HeaderFacets  : [
        {
            $Type : 'UI.ReferenceFacet',
            Target : '@UI.DataPoint#rendimiento',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target : '@UI.DataPoint#combustible',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target : '@UI.DataPoint#Estado',
        },
        
    ],
    LineItem : [
      { Value : fecha, Label : 'Fecha' },
      { Value : ruta.descripcion, Label : 'Ruta' },
      { Value : ruta.distanciaKm, Label : 'Km Ruta'},
      { Value : choferNombreCompleto, Label : 'Chofer' },
      { Value : horaSalida, Label : 'Hora salida' },
      { Value : horaLlegada, Label : 'Hora llegada estimada' },
      { Value : horaLlegadaReal, Label : 'Hora llegada real' },
      { Value : litrosSalida, Label : 'Litros viaje' },
      { Value : pesoCarga, Label : 'Peso carga' }
    ],

    FieldGroup  : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : ruta_ID,
            },
        ],
    },
    Facets : [
      {
        $Type : 'UI.ReferenceFacet',
        ID : 'DatosViaje',
        Label : 'Datos del viaje',
        Target : '@UI.Identification'
      }
    ],
    Identification : [
      { Value : fecha, Label : 'Fecha' },
      { Value : ruta_ID, Label : 'Ruta' },
      { Value : vehiculo_ID, Label : 'Vehiculo' },
      { Value : chofer_ID, Label : 'Chofer' },
      { Value : proveedor_ID, Label : 'Proveedor' },
      { Value : estatus, Label : 'Estatus' },
      { Value : horaSalida, Label : 'Hora salida' },
      { Value : horaLlegada, Label : 'Hora llegada estimada' },
      { Value : horaLlegadaReal, Label : 'Hora llegada real' },
      { Value : litrosSalida, Label : 'Litros viaje' },
      { Value : pesoCarga, Label : 'Peso carga' },
      { Value : rubro_ID, Label : 'Rubro' },
      { Value : pesoIda, Label : 'Peso ida' },
      { Value : pesoVuelta, Label : 'Peso vuelta' },
    ]
  }
) {
  vehiculo @title : 'Vehiculo'
    @Common.Text : vehiculo.placa
    @Common.TextArrangement : #TextOnly
    @Common.ValueList : {
      CollectionPath : 'Vehiculos',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : vehiculo_ID,
          ValueListProperty : 'ID'
        },
        {
          $Type : 'Common.ValueListParameterConstant',
          ValueListProperty : 'estadodelvehiculo_code',
          Constant : 'Operativo'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'placa'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'modelo'
        }
      ]
    };
  ruta @title : 'Ruta'
    @Common.Text : ruta.descripcion
    @Common.TextArrangement : #TextOnly
    @Common.ValueList : {
      CollectionPath : 'Rutas',
      PresentationVariantQualifier : 'RutaVH',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterIn',
          LocalDataProperty : ruta_ID,
          ValueListProperty : 'ID'
        },
        {
          $Type : 'Common.ValueListParameterOut',
          LocalDataProperty : ruta_ID,
          ValueListProperty : 'ID'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'descripcion'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'distanciaKm'
        }
      ]
    };
  chofer @title : 'Chofer'
    @Common.Text : chofer.nombreCompleto
    @Common.TextArrangement : #TextOnly
    @Common.ValueList : {
      CollectionPath : 'Choferes',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : chofer_ID,
          ValueListProperty : 'ID'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'nombreCompleto'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'cedula'
        }
      ]
    };
  estatus @title : 'Estatus'
    @Common.Text : estatusRef.descr
    @Common.TextArrangement : #TextOnly
    @Common.ValueListWithFixedValues : true
    @Common.ValueList : {
      CollectionPath : 'EstadoViajes',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : estatus,
          ValueListProperty : 'code'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'name'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'descr'
        }
      ]
    };
  createdAt @UI.Hidden;
  createdBy @UI.Hidden;
  modifiedAt @UI.Hidden;
  modifiedBy @UI.Hidden;
  fecha @UI.Hidden;
  minHoraSalida @UI.Hidden;
  proveedor @title : 'Proveedor'
    @Common.Text : proveedor.nombre
    @Common.TextArrangement : #TextOnly
    @Common.ValueList : {
      CollectionPath : 'Proveedores',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : proveedor_ID,
          ValueListProperty : 'ID'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'nombre'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'contacto'
        }
      ]
    };
    rendimientoTeorico @Measures.Unit : 'km/L';
    combustibleTeorico @Measures.Unit : 'L';
    costoTeorico @Measures.Unit : 'USD';
    rubro @title : 'Rubro' @Common : { 
      Text : rubro.name,
      TextArrangement : #TextOnly,
      ValueList : {
          $Type : 'Common.ValueListType',
          CollectionPath : 'Rubros',
          Parameters : [
              {
                  $Type : 'Common.ValueListParameterInOut',
                  LocalDataProperty : rubro_ID,
                  ValueListProperty : 'ID',
              },
              {
                  $Type : 'Common.ValueListParameterDisplayOnly',
                  ValueListProperty : 'name',
              },
              {
                  $Type : 'Common.ValueListParameterDisplayOnly',
                  ValueListProperty : 'description',
              },
          ],
      },
    }
};

annotate ConfigService.Rutas with @UI.LineItem #RutaVH : [
  { Value : descripcion, Label : 'Descripcion' },
  { Value : distanciaKm, Label : 'Distancia (km)' }
];

annotate ConfigService.Rutas with @UI.PresentationVariant #RutaVH : {
  Visualizations : ['@UI.LineItem#RutaVH']
};

annotate ConfigService.Viajes with @(
  UI.LineItem #SubTablaChofer : [
    { Value : fecha, Label : 'Fecha' },
    { Value : ruta.descripcion, Label : 'Ruta' },
    { Value : choferNombreCompleto, Label : 'Chofer' },
    { Value : estatus, Label : 'Estatus' },
    { Value : horaSalida, Label : 'Hora salida' },
    { Value : horaLlegada, Label : 'Hora llegada estimada' },
    { Value : horaLlegadaReal, Label : 'Hora llegada real' },
    { Value : litrosSalida, Label : 'Litros viaje' },
    { Value : pesoCarga, Label : 'Peso carga' }
  ],
  Capabilities.InsertRestrictions #SubTablaChofer : { Insertable : false },
  UI.DataPoint#rendimiento : {
    $Type : 'UI.DataPointType',
    Value: rendimientoTeorico,
    Criticality: #Information,
    Title : 'Rendimiento'
  },
  UI.DataPoint#combustible : {
    $Type : 'UI.DataPointType',
    Value: combustibleTeorico,
    Criticality: #Information,
    Title: 'Combustible'
  },
  UI.DataPoint#Estado : {
    $Type : 'UI.DataPointType',
    Value: estatus,
    Criticality: #Information,
    Title: 'Estado del viaje'
  },
  UI.DataPoint#costo : {
    $Type : 'UI.DataPointType',
    Value: costoTeorico,
    Criticality: #Information,
    Title: 'Costo'
  },
  Common.SideEffects : {
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
      
  },
);
