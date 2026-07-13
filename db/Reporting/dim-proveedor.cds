namespace gas.reporting;

entity DimProveedor {
  key proveedor_ID      : UUID;
      nombre             : String;
      capacidadDespacho  : Decimal(10,2);
      precioPromedio     : Decimal(10,2);
}
