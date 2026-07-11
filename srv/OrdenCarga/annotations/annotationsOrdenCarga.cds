using { ConfigService } from '../../service';

annotate ConfigService.OrdenesCarga with @(
  odata.draft.enabled,
  Capabilities : {
    InsertRestrictions : { Insertable : true },
    UpdateRestrictions : { Updatable : true },
    DeleteRestrictions : { Deletable : true }
  },
  UI : {
    HeaderInfo : {
      TypeName : 'Orden de Carga',
      TypeNamePlural : 'Ordenes de Carga',
      Title : { Value : placaCamionCisterna },
      Description : { Value : fechaCarga }
    },
    LineItem : [
      { Value : fechaCarga, Label : 'Fecha carga', Importance : #High },
      { Value : tanque.codigo, Label : 'Codigo tanque', Importance : #High },
      { Value : placaCamionCisterna, Label : 'Placa camion cisterna', Importance : #High },
      { Value : nombreChoferCisterna, Label : 'Chofer cisterna', Importance : #High },
      { Value : carga_real, Label : 'Carga real', Importance : #Medium },
      { Value : carga_facturada, Label : 'Carga facturada', Importance : #Medium },
      { Value : variacion, Label : 'Variacion', Importance : #Medium },
      { Value : porcentaje_conciliacion, Label : '% conciliacion', Importance : #Medium }
    ],
    Identification : [
      { Value : fechaCarga, Label : 'Fecha carga' },
      { Value : proveedor_ID, Label : 'Proveedor' },
      { Value : almacen_ID, Label : 'Almacen' },
      { Value : placaCamionCisterna, Label : 'Placa camion cisterna' },
      { Value : nombreChoferCisterna, Label : 'Chofer cisterna' },
      { Value : cedulaChoferCisterna, Label : 'Cedula chofer cisterna' },
      { Value : carga_real, Label : 'Carga real' },
      { Value : carga_facturada, Label : 'Carga facturada' },
      { Value : observacion, Label : 'Observacion' },
      { Value : variacion, Label : 'Variacion' },
      { Value : porcentaje_conciliacion, Label : '% conciliacion' },
      { Value : precio, Label : 'precio' },

    ],
    Facets  : [
        {
            $Type : 'UI.ReferenceFacet',
            Target : '@UI.Identification',
            Label : 'Datos Generales'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target : 'to_tanques/@UI.LineItem',
            Label : 'Tanques asociados'
        },
    ],
  }
) {
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
          ValueListProperty : 'telefono'
        }
      ]
    };
  tanque @title : 'Tanque'
    @Common.Text : tanque.tipo_combustible
    @Common.TextArrangement : #TextOnly
    @Common.ValueList : {
      CollectionPath : 'Tanques',
      Parameters : [
        {
            $Type : 'Common.ValueListParameterIn',
            LocalDataProperty : almacen_ID,
            ValueListProperty : 'almacen_ID',
        },
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : tanque_ID,
          ValueListProperty : 'ID'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'tipo_combustible'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'capacidadTotal'
        },
        {
          $Type : 'Common.ValueListParameterConstant',
          ValueListProperty : 'estadoTanque_code',
          Constant : 'Operativo'
        }
      ]
    };
  placaCamionCisterna @title : 'Placa camion cisterna';
  nombreChoferCisterna @title : 'Chofer cisterna';
  cedulaChoferCisterna @title : 'Cedula chofer cisterna';
  cedula_chofer @title : 'Chofer'
    @Common.Text : choferNombreCompleto
    @Common.TextArrangement : #TextOnly
    @Common.ValueList : {
      CollectionPath : 'Choferes',
      Parameters : [
        {
          $Type : 'Common.ValueListParameterInOut',
          LocalDataProperty : cedula_chofer,
          ValueListProperty : 'cedula'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'nombre'
        },
        {
          $Type : 'Common.ValueListParameterDisplayOnly',
          ValueListProperty : 'apellido'
        }
      ]
    };
  porcentaje_conciliacion @readonly @Measures.Unit: '%';
  variacion @Measures.Unit: 'L' @readonly;
  carga_real @Measures.Unit: 'L';
  carga_facturada @Measures.Unit: 'L';
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
      ]
    };
  precio @Measures.Unit: 'USD' @readonly
}
annotate ConfigService.OrdenesCarga with @(
  Common.SideEffects: {
    SourceProperties : [
        carga_facturada,
        carga_real,
      proveedor_ID
    ],
    TargetProperties : [
        'variacion',
        'porcentaje_conciliacion',
        'precio'
    ],
  }
);

annotate ConfigService.TankXOrden with @(
  UI: {
    LineItem  : [
      {
          $Type : 'UI.DataField',
        Value :  tanque_ID,
        Label : 'Codigo tanque',
      },
      {
          $Type : 'UI.DataField',
          Value : quantity,
          Label : 'Cantidad',
      },
    ],
  }
){
  tanque @Common: {
    Text           : tanque.codigo,
    TextArrangement: #TextOnly,
    ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'Tanques',
        Parameters : [
             {
                 $Type : 'Common.ValueListParameterIn',
                 LocalDataProperty : orden.almacen_ID,
               ValueListProperty : 'almacen_ID',
             },
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : tanque_ID,
                ValueListProperty : 'ID',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'tipo_combustible',
            },
            {
              $Type : 'Common.ValueListParameterConstant',
              ValueListProperty : 'estadoTanque_code',
              Constant : 'Operativo',
            },
        ],
    },
  };
  quantity @Measures.Unit: 'L';
};  