using { ConfigService } from '../../service';

annotate ConfigService.Tanques with @(
  Capabilities : {
    InsertRestrictions : { Insertable : true },
    UpdateRestrictions : { Updatable : true },
    DeleteRestrictions : { Deletable : true }
  },
  UI : {
    HeaderInfo : {
      TypeName : 'Tanque',
      TypeNamePlural : 'Tanques',
      Title : { Value : descripcion },
      Description : { Value : capacidadTotal }
    },
    DataPoint #NivelTanque : {
      $Type : 'UI.DataPointType',
      Title : 'Nivel de combustible',
      Value : nivel_actual,
      TargetValue : capacidadTotal,
      Criticality : nivelCriticality,
      Visualization : #BulletChart,
      ValueFormat : {
        $Type : 'UI.NumberFormat',
        NumberOfFractionalDigits : 2
      }
    },
    LineItem : [
      { $Type : 'UI.DataField', Value : tipo_combustible, Label : 'Tipo combustible', Importance : #High },
      { $Type : 'UI.DataField', Value : capacidadTotal, Label : 'Capacidad total', Importance : #High },
      { $Type : 'UI.DataField', Value : nivel_actual, Label : 'Nivel actual', Importance : #Medium },
      { $Type : 'UI.DataField', Value : nivel_minimo, Label : 'Nivel minimo', Importance : #Medium },
      { $Type : 'UI.DataField', Value : ultimaFechaRecarga, Label : 'Ultima recarga', Importance : #Medium },
      { $Type : 'UI.DataField', Value : estadoTanque_code, Label : 'Estado del tanque', Importance : #Medium }
    ],
    Facets : [
      {
        $Type : 'UI.ReferenceFacet',
        ID : 'DatosTanque',
        Label : 'Datos del tanque',
        Target : '@UI.Identification'
      },
      {
        $Type : 'UI.ReferenceFacet',
        ID : 'OrdenesCarga',
        Label : 'Ordenes de carga',
        Target : 'ordenesCarga/@UI.LineItem'
      }
    ],
    Identification : [
      { Value : almacen_ID, Label : 'Almacen' },
      { Value : descripcion, Label : 'Nombre del tanque' },
      { Value : codigo, Label : 'Codigo' },
      { Value : tipo_combustible, Label : 'Tipo combustible' },
      { Value : capacidadTotal, Label : 'Capacidad total' },
      { Value : nivel_minimo, Label : 'Nivel minimo' },
      { Value : nivel_actual, Label : 'Nivel actual' },
      { Value : ultimaFechaRecarga, Label : 'Ultima recarga' },
      { $Type : 'UI.DataField', Value : estadoTanque_code, Label : 'Estado del tanque' }
    ]
  }
) {
  almacen @title : 'Almacen'
    @Common.Text : almacen.nombreSede
    @Common.TextArrangement : #TextOnly
    @Common.ValueList : {
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
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'ubicacion'
        }
      ]
    };

  codigo @Common.FieldControl : #ReadOnly;

  estadoTanque @title : 'Estado del tanque'
    @Common.ValueListWithFixedValues : true
    @Common.Text : estadoTanque.code
    @Common.TextArrangement : #TextOnly
    @Common.ValueList : {
      CollectionPath : 'TanqueEstados',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : estadoTanque_code,
          ValueListProperty : 'code'
        }
      ]
    };
}
