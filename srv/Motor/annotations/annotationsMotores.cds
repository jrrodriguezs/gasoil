
using { ConfigService } from '../../service';

annotate ConfigService.Motores with @(
  odata.draft.enabled,
  Capabilities : {
    InsertRestrictions : { Insertable : true },
    UpdateRestrictions : { Updatable : true },
    DeleteRestrictions : { Deletable : true }
  },
  UI : {
    HeaderInfo : {
      TypeName : 'Motor',
      TypeNamePlural : 'Motores',
      Title : { Value : modelo },
      Description : { Value : serie }
    },
    SelectionFields : [ modelo, serie, tipoEmision_code ],
    FieldGroup #DatosMotor : {
      $Type : 'UI.FieldGroupType',
      Data : [
        { $Type : 'UI.DataField', Value : modelo, Label : 'Modelo' },
        { $Type : 'UI.DataField', Value : serie, Label : 'Serie' },
        { $Type : 'UI.DataField', Value : tipoEmision_code, Label : 'Tipo de emision' }
      ]
    },
    FieldGroup #Especificaciones : {
      $Type : 'UI.FieldGroupType',
      Data : [
        { $Type : 'UI.DataField', Value : factorEficiencia, Label : 'Factor eficiencia' },
        { $Type : 'UI.DataField', Value : torqueMax, Label : 'Torque max' },
        { $Type : 'UI.DataField', Value : cilindrada, Label : 'Cilindrada' }
      ]
    },
    LineItem : [
      { Value : modelo, Label : 'Modelo', Importance : #High },
      { Value : serie, Label : 'Serie', Importance : #High },
      { Value : torqueMax, Label : 'Torque max', Importance : #Medium },
      { Value : cilindrada, Label : 'Cilindrada', Importance : #Medium },
      { Value : tipoEmision_code, Label : 'Tipo de emision', Importance : #Medium }
    ],
    Facets : [
      {
        $Type : 'UI.ReferenceFacet',
        ID : 'DatosMotor',
        Label : 'Datos del motor',
        Target : '@UI.FieldGroup#DatosMotor'
      },
      {
        $Type : 'UI.ReferenceFacet',
        ID : 'Especificaciones',
        Label : 'Especificaciones',
        Target : '@UI.FieldGroup#Especificaciones'
      }
    ],
    Identification : [
      { $Type : 'UI.DataField', Value : modelo, Label : 'Modelo' },
      { $Type : 'UI.DataField', Value : serie, Label : 'Serie' },
      { $Type : 'UI.DataField', Value : factorEficiencia, Label : 'Factor eficiencia' },
      { $Type : 'UI.DataField', Value : torqueMax, Label : 'Torque max' },
      { $Type : 'UI.DataField', Value : cilindrada, Label : 'Cilindrada' },
      { $Type : 'UI.DataField', Value : tipoEmision_code, Label : 'Tipo de emision' }
    ]
  }
) {
  modelo @title : 'Modelo';
  tipoEmision @title : 'Tipo de emision'
    @Common.ValueListWithFixedValues : true;

}



