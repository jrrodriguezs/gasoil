using { ConfigService } from '../../service';


annotate ConfigService.Choferes with @(
  odata.draft.enabled,
  Capabilities : {
    InsertRestrictions : { Insertable : true },
    UpdateRestrictions : { Updatable : true },
    DeleteRestrictions : { Deletable : true }
  },
  UI : {
    HeaderInfo : {
      TypeName : 'Chofer',
      TypeNamePlural : 'Choferes',
      ImageUrl : choferImage,
      Title : { Value : nombre }
    },
    DataPoint #Rendimiento : {
      $Type : 'UI.DataPointType',
      Visualization : #Rating,
      Value : rendimiento.qualifier,
      Criticality : rendimiento.criticality,
      Title : 'Rendimiento del chofer'
    },
    FieldGroup : {
      $Type : 'UI.FieldGroupType',
      Data : [
        { $Type : 'UI.DataField', Value : nombre, Label : 'Nombre' },
        { $Type : 'UI.DataField', Value : apellido, Label : 'Apellido' },
        { $Type : 'UI.DataField', Value : cedula, Label : 'Cedula' },
        { $Type : 'UI.DataField', Value : telefono, Label : 'Telefono' },
        { $Type : 'UI.DataField', Value : direccion, Label : 'Direccion' }
      ]
    },
    HeaderFacets : [
      { $Type : 'UI.ReferenceURLFacet', Target : '@UI.HeaderInfo' },
      { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup', Label : 'Datos del chofer' },
      { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#Rendimiento', Label : 'Rendimiento del chofer' }
    ],
    SelectionFields : [ nombre, apellido, cedula, telefono, rendimiento_code ],
    LineItem : [
      { $Type : 'UI.DataField', Value : choferImage, Label : 'Foto del chofer' },
      { Value : cedula, Label : 'Cedula', Importance : #High },
      { Value : nombre, Label : 'Nombre', Importance : #High },
      { Value : apellido, Label : 'Apellido', Importance : #High },
      { Value : telefono, Label : 'Telefono', Importance : #Medium },
      { $Type : 'UI.DataFieldForAnnotation', Target : @UI.DataPoint#Rendimiento}
    ],
     LineItem #HistoricoViajes : [
      { Value : viaje.fecha, Label : 'Fecha' },
      { Value : viaje.ruta.destino, Label : 'Ruta' },
      { Value : viaje.ruta.distanciaKm, Label : 'Km Ruta'},
      { Value : nombreCompleto, Label : 'Chofer' },
      { Value : viaje.horaSalida, Label : 'Hora salida' },
      { Value : viaje.horaLlegada, Label : 'Hora llegada estimada' },
      { Value : viaje.horaLlegadaReal, Label : 'Hora llegada real' },
      { Value : viaje.litrosSalida, Label : 'Litros viaje' },
      { Value : viaje.pesoCarga, Label : 'Peso carga' }
    ],
    Identification : [
      { $Type : 'UI.DataField', Value : nombre, Label : 'Nombre' },
      { $Type : 'UI.DataField', Value : apellido, Label : 'Apellido' },
      { $Type : 'UI.DataField', Value : cedula, Label : 'Cedula' },
      { $Type : 'UI.DataField', Value : telefono, Label : 'Telefono' },
      { $Type : 'UI.DataField', Value : direccion, Label : 'Direccion' }
    ],
    Facets : [
      {
        $Type : 'UI.ReferenceFacet',
        ID : 'DatosChofer',
        Label : 'Datos del chofer',
        Target : '@UI.Identification'
      },
      {
        $Type : 'UI.ReferenceFacet',
        ID : 'Viajes',
        Label : 'Historico de viajes',
        Target : 'viajes/@UI.LineItem',
        ![@UI.Hidden] : { $edmJson : { $If : [ { $Eq : [ { $Path : 'IsActiveEntity' }, false ] }, true, false ] } }
      }
    ]
  }
) {
  choferImage @UI.IsImageURL;
  rendimiento @Common.ValueListWithFixedValues : true @title : 'Rendimiento del Chofer';
  telefono @assert.format : '^\d{11}$';
  cedula @assert.format : '^\d{7,}$';
  viajes @Capabilities.InsertRestrictions : { Insertable : false };

}