namespace gas.reporting;

entity DimVehiculo {
  key vehiculo_ID       : UUID;
      placa              : String;
      modelo             : String;
      motorModelo        : String;
      transmisionModelo  : String;
      cajaModelo         : String;
      ejes               : String;
      configuracion      : String;
      capacidadTotal     : Decimal(10,2); // combustible (litros)
      cargautil          : Decimal(10,2); // carga útil (toneladas)
      estado             : String;
      antiguedadDias     : Integer;
      categoriaCarga     : String;
}
