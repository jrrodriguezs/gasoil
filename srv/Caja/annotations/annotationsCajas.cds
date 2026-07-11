using { ConfigService } from '../../service';

annotate ConfigService.Cajas with @(
  odata.draft.enabled,
  Capabilities : {
    InsertRestrictions : { Insertable : true },
    UpdateRestrictions : { Updatable : true },
    DeleteRestrictions : { Deletable : true }
  },
  UI : {
    HeaderInfo : {
      TypeName : 'Caja',
      TypeNamePlural : 'Cajas',
      Title : { Value : modeloCaja },
      Description : { Value : numeroVelocidades }
    },
    SelectionFields : [ modeloCaja, numeroVelocidades ],
    LineItem : [
      { Value : modeloCaja, Label : 'Modelo caja', Importance : #High },
      { Value : numeroVelocidades, Label : 'Numero velocidades', Importance : #High },
      { Value : factorTransmision, Label : 'Factor transmision', Importance : #Medium }
    ],
    FieldGroup #Main : {
      Data : [
        { $Type : 'UI.DataField', Value : modeloCaja, Label : 'Modelo caja' },
        { $Type : 'UI.DataField', Value : numeroVelocidades, Label : 'Numero velocidades' },
        { $Type : 'UI.DataField', Value : factorTransmision, Label : 'Factor transmision' }
      ]
    },
    Facets : [
      {
        $Type : 'UI.ReferenceFacet',
        Label : 'Detalles',
        Target : '@UI.FieldGroup#Main'
      }
    ],
    Identification : [
      { $Type : 'UI.DataField', Value : modeloCaja, Label : 'Modelo caja' },
      { $Type : 'UI.DataField', Value : numeroVelocidades, Label : 'Numero velocidades' },
      { $Type : 'UI.DataField', Value : factorTransmision, Label : 'Factor transmision' }
    ]
  }
) {
  ID @UI.Hidden;
  numeroVelocidades @assert : (case when numeroVelocidades is null or numeroVelocidades <= 0 or numeroVelocidades > 24 then 'El número de velocidades debe ser mayor que 0 y menor o igual a 24' end);
  factorTransmision @assert : (case when factorTransmision is null or factorTransmision <= 0 or factorTransmision > 10 then 'El factor de transmisión debe ser mayor que cero y menor o igual a diez' end);

}
