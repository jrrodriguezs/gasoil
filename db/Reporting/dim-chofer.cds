namespace gas.reporting;

entity DimChofer {
  key chofer_ID         : UUID;
      nombreCompleto     : String;
      cedula             : String;
      rendimientoQual    : String;    // Bueno, Regular, Malo
      viajesTotales      : Integer;
      experienciaMeses   : Integer;
}
