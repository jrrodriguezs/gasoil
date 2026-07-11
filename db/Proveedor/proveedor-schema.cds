using { managed, cuid } from '@sap/cds/common';

namespace gas.app;

entity Proveedor : managed, cuid {
  @mandatory nombre             : String;
  @mandatory telefono           : String;
  @mandatory capacidad_despacho : Decimal(10,2);
  direccion           : String;
  precios            : Composition of many PrecioHistorico on precios.proveedor = $self;
}

entity PrecioHistorico : managed, cuid {
  proveedor    : Association to Proveedor;
  precioCombustible : Decimal(10,2);
  precio       : Decimal(10,2);
  litros_distribuidos : Decimal(10,2);
  fecha        : Date;
}
