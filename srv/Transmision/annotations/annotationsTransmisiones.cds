using { ConfigService } from '../../service';

annotate ConfigService.Transmisiones with @(
  odata.draft.enabled,
  Capabilities : {
    InsertRestrictions : { Insertable : true },
    UpdateRestrictions : { Updatable : true },
    DeleteRestrictions : { Deletable : true }
  },
  UI : {
    HeaderInfo : {
      TypeName : 'Transmision',
      TypeNamePlural : 'Transmisiones',
      Title : { Value : modeloDiferencial },
      Description : { Value : tipoEje }
    },
    SelectionFields : [ modeloDiferencial, tipoEje ],
    LineItem : [
      { Value : modeloDiferencial, Label : 'Modelo diferencial', Importance : #High },
      { Value : relacionTransmision, Label : 'Relacion transmision', Importance : #High },
      { Value : factorTransmision, Label : 'Factor transmision', Importance : #High },
      { Value : tipoEje, Label : 'Tipo de eje', Importance : #Medium },
      { Value : capacidadCargaEje, Label : 'Capacidad carga eje', Importance : #Medium }
    ],
    FieldGroup #Main : {
      Data : [
        { $Type : 'UI.DataField', Value : modeloDiferencial, Label : 'Modelo diferencial' },
        { $Type : 'UI.DataField', Value : relacionTransmision, Label : 'Relacion transmision' },
        { $Type : 'UI.DataField', Value : factorTransmision, Label : 'Factor transmision' },
        { $Type : 'UI.DataField', Value : tipoEje, Label : 'Tipo de eje' },
        { $Type : 'UI.DataField', Value : capacidadCargaEje, Label : 'Capacidad carga eje' }
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
      { $Type : 'UI.DataField', Value : modeloDiferencial, Label : 'Modelo diferencial' },
      { $Type : 'UI.DataField', Value : relacionTransmision, Label : 'Relacion transmision' },
      { $Type : 'UI.DataField', Value : factorTransmision, Label : 'Factor transmision' },
      { $Type : 'UI.DataField', Value : tipoEje, Label : 'Tipo de eje' },
      { $Type : 'UI.DataField', Value : capacidadCargaEje, Label : 'Capacidad carga eje' }
    ]
  }
) {
  ID @UI.Hidden;
};
