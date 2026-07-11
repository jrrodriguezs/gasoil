using { ConfigService } from '../../service';


annotate ConfigService.Vehiculos with {
  kmTotales     @Measures.Unit : 'km';
  litrosTotales @Measures.Unit : 'l';
  promedioKm    @Measures.Unit : 'km/l'
};


annotate ConfigService.Vehiculos with @(
  odata.draft.enabled,
  Capabilities : {
    InsertRestrictions : { Insertable : true },
    UpdateRestrictions : { Updatable : true },
    DeleteRestrictions : { Deletable : true }
  },
  Common.SideEffects : {
    SourceProperties : [ capacidadTanque1, capacidadTanque2, numeroTanques ],
    TargetProperties : [ capacidadTotal, capacidadTanque2 ]
  },
  UI : {
    HeaderInfo : {
      TypeName : 'Vehiculo',
      TypeNamePlural : 'Vehiculos',
      ImageUrl       : imageVehiculo,
      Title : { Value : placa },
      Description : { Value : modelo }
    },
    HeaderFacets : [
      { $Type : 'UI.ReferenceURLFacet', Target : '@UI.HeaderInfo'},
      { $Type : 'UI.ReferenceFacet'   , Target : '@UI.DataPoint#KmToatles' },
      { $Type : 'UI.ReferenceFacet'   , Target : '@UI.DataPoint#LtrosTotales' },
      { $Type : 'UI.ReferenceFacet'   , Target : '@UI.DataPoint#RendimientoBase' },
      { $Type : 'UI.ReferenceFacet'   , Target : '@UI.DataPoint#RendimientoReal' },
      { $Type : 'UI.ReferenceFacet'   , Target : '@UI.DataPoint#CargaUtil' },
      { $Type : 'UI.ReferenceFacet'   , Target : '@UI.DataPoint#EstadoUnidad' }
    ],
    DataPoint #RendimientoBase : {
      Value : rendimientoBase,
      Criticality : #Positive,
      Title : 'Rendimiento base del vehiculo'
    },
    DataPoint #RendimientoReal : {
      Value : promedioKm,
      Criticality : #Information,
      ValueFormat : {
          $Type : 'UI.NumberFormat',
          NumberOfFractionalDigits : 2,
          ScaleFactor : promedioKm,
      },
      Title : 'Rendimiento real del vehiculo'
    },
    DataPoint #CargaUtil : {
      Value : cargautil,
      Criticality : #Information,
      Title : 'Carga util de la unidad'
    },
    DataPoint #EstadoUnidad : {
      Value : estadodelvehiculo_code,
      Criticality : estadodelvehiculo.criticality,
      Title : 'Estado de la unidad'
    },
    DataPoint #KmToatles : {
      Value : kmTotales,
      Criticality : estadodelvehiculo.criticality,
      Title : 'Total de km recorridos'
    },
    DataPoint #LtrosTotales : {
      Value : litrosTotales,
      Criticality : estadodelvehiculo.criticality,
      Title : 'Total litros consumidos'
    },

    LineItem : [
      { Value : placa, Label : 'Placa', Importance : #High },
      { Value : modelo, Label : 'Modelo', Importance : #High },
      { Value : nivelActualCombustible, Label : 'Nivel actual combustible', Importance : #Medium },
      { Value : numeroTanques, Label : 'Numero de tanques', Importance : #Medium },
      { Value : ejescamion_code, Label : 'Ejes', Importance : #Medium },
      { Value : capacidadTotal, Label : 'Capacidad total (L)', Importance : #Medium },
      { Value : rendimientoBase, Label : 'Rendimiento base', Importance : #Medium },
      {
        $Type : 'UI.DataField',
        Value : estadodelvehiculo_code,
        Label : 'Estado',
        Criticality : estadodelvehiculo.criticality
      }
    ],
    Facets : [
      {
        $Type : 'UI.ReferenceFacet',
        ID : 'DatosVehiculo',
        Label : 'Datos del vehiculo',
        Target : '@UI.Identification'
      },
      {
        $Type : 'UI.ReferenceFacet',
        ID : 'Viajes',
        Label : 'Historico de viajes',
        Target : 'viajes/@UI.LineItem',
        ![@UI.Hidden] : { $edmJson : { $If : [ { $Eq : [ { $Path : 'IsActiveEntity' }, false ] }, true, false ] } }
      }
    ],
    Identification : [
      { $Type : 'UI.DataField', Value : placa, Label : 'Placa' },
      { $Type : 'UI.DataField', Value : modelo, Label : 'Modelo' },
      { $Type : 'UI.DataField', Value : ejescamion_code, Label : 'Ejes' },
      {
        $Type : 'UI.DataField',
        Value : configuraciondelremolque,
        Label : 'Configuracion'
      },
      { $Type : 'UI.DataField', Value : caja_ID, Label : 'Caja' },
      { $Type : 'UI.DataField', Value : transmision_ID, Label : 'Transmision' },
      { $Type : 'UI.DataField', Value : motor_ID, Label : 'Motor' },
      {
        $Type : 'UI.DataField',
        Value : numeroTanques,
        Label : 'Numero de tanques'
      },
      {
        $Type : 'UI.DataField',
        Value : capacidadTanque1,
        Label : 'Capacidad tanque 1'
      },
      {
        $Type : 'UI.DataField',
        Value : capacidadTanque2,
        Label : 'Capacidad tanque 2'
      },
      {
        $Type : 'UI.DataField',
        Value : capacidadTotal,
        Label : 'Capacidad total'
      },
      {
        $Type : 'UI.DataField',
        Value : nivelActualCombustible,
        Label : 'Nivel actual combustible'
      },
      {
        $Type : 'UI.DataField',
        Value : rendimientoBase,
        Label : 'Rendimiento base'
      },
      { $Type : 'UI.DataField', Value : cargautil, Label : 'Carga util' },
      {
        $Type : 'UI.DataField',
        Value : estadodelvehiculo_code,
        Label : 'Estado',
        Criticality : estadodelvehiculo.criticality
      }
    ]
  }
) {
  estadodelvehiculo @title : 'Estado del Vehiculo'
    @Common.ValueListWithFixedValues : true;
  ejescamion @title : 'Ejes del Camion'
    @Common.ValueListWithFixedValues : true;
  configuraciondelremolque @title : 'Configuracion'
    @Common.ValueListWithFixedValues : true
    @Common.ValueList : {
      CollectionPath : 'ConfiguracionCamiones',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : configuraciondelremolque,
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
  numeroTanques @title : 'Numero de tanques'
    @Common.Text : numeroTanquesRef.descr
    @Common.TextArrangement : #TextOnly
    @Common.ValueListWithFixedValues : true
    @Common.ValueList : {
      CollectionPath : 'NumeroTanquesVH',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : numeroTanques,
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
  caja @title : 'Caja'
    @Common.Text : caja.modeloCaja
    @Common.TextArrangement : #TextOnly
    @Common.ValueList : {
      CollectionPath : 'Cajas',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : caja_ID,
          ValueListProperty : 'ID'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'modeloCaja'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'numeroVelocidades'
        }
      ]
    };
  transmision @title : 'Transmision'
    @Common.Text : transmision.modeloDiferencial
    @Common.TextArrangement : #TextOnly
    @Common.ValueList : {
      CollectionPath : 'Transmisiones',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : transmision_ID,
          ValueListProperty : 'ID'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'modeloDiferencial'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'tipoEje'
        }
      ]
    };
  motor @title : 'Motor'
    @Common.Text : motor.modelo
    @Common.TextArrangement : #TextOnly
    @Common.ValueList : {
      CollectionPath : 'Motores',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : motor_ID,
          ValueListProperty : 'ID'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'serie'
        }
      ]
    };
  rendimientoBase @Measures.Unit : measure;
  rendimientoReal @Measures.Unit : measure;
  cargautil @Measures.Unit : 't';
  measure @Common.IsUnit;
  capacidadTotal @Common.FieldControl : #ReadOnly;
  viajes @Capabilities.InsertRestrictions : { Insertable : false };
};
