using { ConfigService } from '../../service';

annotate ConfigService.SurtidosUnidad with @(
  odata.draft.enabled,
  Capabilities : {
    InsertRestrictions : { Insertable : true },
    UpdateRestrictions : { Updatable : true },
    DeleteRestrictions : { Deletable : true }
  },
  UI : {
    HeaderInfo : {
      TypeName : 'Surtido por Unidad',
      TypeNamePlural : 'Surtidos por Unidad',
      Title : { Value : responsable },
      Description : { Value : fechaCarga }
    },
    LineItem : [
      { Value : fechaCarga, Label : 'Fecha carga', Importance : #High },
      { Value : responsable, Label : 'Responsable', Importance : #High },
      { Value : almacen.nombreSede, Label : 'Almacen', Importance : #High },
      { Value : vehiculo.placa, Label : 'Vehiculo', Importance : #High },
      { Value : tanque.descripcion, Label : 'Tanque', Importance : #High },
      { Value : carga_real, Label : 'Carga Surtida', Importance : #High },
      { Value : volumenPrevioVehiculo, Label : 'Volumen previo del vehiculo', Importance : #Medium },
      { Value : volumen_actual_vehiculo, Label : 'Capacidad del vehiculo', Importance : #Medium },
      { Value : cargaExterna, Label : 'Carga externa', Importance : #Low },
      { Value : nombreEstacionServicio, Label : 'Estacion servicio', Importance : #Low },
      { Value : precioCombustible, Label : 'Precio combustible', Importance : #Low }
    ],
    Identification : [
      {
        Value : almacen_ID,
        Label : 'Almacen',
        ![@UI.Hidden] : {
          $edmJson : {
            $If : [
              { $Eq : [ { $Path : 'cargaExterna' }, true ] },
              true,
              false
            ]
          }
        }
      },
      {
        Value : tanque_ID,
        Label : 'Tanque',
        ![@UI.Hidden] : {
          $edmJson : {
            $If : [
              { $Eq : [ { $Path : 'cargaExterna' }, true ] },
              true,
              false
            ]
          }
        },
        ![@Common.FieldControl] : {
          $edmJson : {
            $If : [
              {
                $Or : [
                  { $Eq : [ { $Path : 'almacen_ID' }, null ] },
                  { $Eq : [ { $Path : 'almacen_ID' }, '' ] }
                ]
              },
              1,
              3
            ]
          }
        }
      },
      { Value : vehiculo_ID, Label : 'Vehiculo' },
      { Value : fechaCarga, Label : 'Fecha carga' },
      { Value : responsable, Label : 'Responsable' },
      { Value : carga_real, Label : 'Carga Surtida' },
      { Value : volumenPrevioVehiculo, Label : 'Volumen previo del vehiculo' },
      { Value : volumen_actual_vehiculo, Label : 'Capacidad del vehiculo' },
      { Value : cargaExterna, Label : 'Carga externa' },
      { Value : nombreEstacionServicio, Label : 'Estacion servicio' },
      { Value : precioCombustible, Label : 'Precio combustible' },

    ],
    Facets  : [
        {
            $Type : 'UI.ReferenceFacet',
            Target : '@UI.Identification',
            Label : 'Datos Generales'
        },
    ],
  }
) {
  vehiculo @title : 'Vehiculo'
    @Common.ValueListWithFixedValues : true
    @Common.ValueList : {
      $Type : 'Common.ValueListType',
      CollectionPath : 'Vehiculos',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : vehiculo_ID,
          ValueListProperty : 'ID'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'placa'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'modelo'
        },
        {
          $Type : 'Common.ValueListParameterOut',
          LocalDataProperty : volumenPrevioVehiculo,
          ValueListProperty : 'nivelActualCombustible'
        },
        {
          $Type : 'Common.ValueListParameterOut',
          LocalDataProperty : volumen_actual_vehiculo,
          ValueListProperty : 'capacidadTotal'
        }
      ]
    }
    @Common.Text : vehiculo.placa
    @Common.TextArrangement : #TextOnly;
  almacen @title : 'Almacen'
    @Common.ValueListWithFixedValues : true
    @Common.ValueList : {
      $Type : 'Common.ValueListType',
      CollectionPath : 'Almacenes',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : almacen_ID,
          ValueListProperty : 'ID'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'nombreSede'
        }
      ]
    }
    @Common.Text : almacen.nombreSede
    @Common.TextArrangement : #TextOnly;
  tanque @title : 'Tanque'
    @Common.ValueListWithFixedValues : true
    @Common.ValueList : {
      $Type : 'Common.ValueListType',
      CollectionPath : 'TanquesDisponibles',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : tanque_ID,
          ValueListProperty : 'ID'
        },
        {
          $Type : 'Common.ValueListParameterIn',
          LocalDataProperty : almacen_ID,
          ValueListProperty : 'almacen_ID'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'descripcion'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'tipo_combustible'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'nivel_actual'
        }
      ]
    }
    @Common.Text : tanque.descripcion
    @Common.TextArrangement : #TextOnly;
  volumen_actual_vehiculo @Measures.Unit: 'L'
    @Common.FieldControl : #ReadOnly;
  volumenPrevioVehiculo @Measures.Unit: 'L'
    @Common.FieldControl : #ReadOnly;
  precioCombustible @Measures.Unit: 'USD';
  carga_real @Measures.Unit: 'L';

  nombreEstacionServicio @UI.Hidden : {
    $edmJson : {
      $If : [
        { $Eq : [ { $Path : 'cargaExterna' }, true ] },
        false,
        true
      ]
    }
  };
  precioCombustible @UI.Hidden : {
    $edmJson : {
      $If : [
        { $Eq : [ { $Path : 'cargaExterna' }, true ] },
        false,
        true
      ]
    }
  };
}
