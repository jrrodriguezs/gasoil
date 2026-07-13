namespace gas.reporting;

entity DimAlmacen {
  key almacen_ID        : UUID;
      nombreSede         : String;
      ubicacion          : String;
      estado             : String;
      capacidadTotal     : Decimal(10,2);
      tanquesCount       : Integer;
}
