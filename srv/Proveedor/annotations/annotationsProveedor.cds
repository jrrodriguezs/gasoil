using { ConfigService } from '../../service';

annotate ConfigService.Proveedores with @(
  odata.draft.enabled,
  Capabilities : {
    InsertRestrictions : { Insertable : true },
    UpdateRestrictions : { Updatable : true },
    DeleteRestrictions : { Deletable : true }
  },
  UI : {
    HeaderInfo : {
      TypeName : 'Proveedor',
      TypeNamePlural : 'Proveedores',
      Title : { Value : nombre },
      Description : { Value : telefono }
    },
    LineItem : [
      { Value : nombre, Label : 'Nombre', Importance : #High },
      { Value : telefono, Label : 'Telefono', Importance : #High },
      { Value : direccion, Label : 'Direccion', Importance : #Medium },
      { Value : capacidad_despacho, Label : 'Capacidad despacho', Importance : #Medium }
    ],
    Facets : [
      {
        $Type : 'UI.ReferenceFacet',
        ID : 'DatosProveedor',
        Label : 'Datos del proveedor',
        Target : '@UI.Identification'
      },
      {
        $Type : 'UI.ReferenceFacet',
        ID : 'PreciosHistoricos',
        Label : 'Historico de precios',
        Target : 'precios/@UI.LineItem'
      }
    ],
    Identification : [
      { Value : nombre, Label : 'Nombre' },
      { Value : telefono, Label : 'Telefono' },
      { Value : direccion, Label : 'Direccion' },
      { Value : capacidad_despacho, Label : 'Capacidad despacho' }
    ]
  }
);

annotate ConfigService.PreciosHistoricos with @(
  UI : {
    LineItem : [
      { Value : fecha, Label : 'Fecha', Importance : #High },
      { Value : precioCombustible, Label : 'Precio combustible', Importance : #High },
      { Value : litros_distribuidos, Label : 'Litros distribuidos', Importance : #High }
    ]
  }
);
