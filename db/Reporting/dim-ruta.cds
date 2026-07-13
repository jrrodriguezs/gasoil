namespace gas.reporting;

entity DimRuta {
  key ruta_ID           : UUID;
      descripcion        : String;
      distanciaKm        : Decimal(10,2);
      destinosCount      : Integer;
      latitud            : Decimal(9,6);
      longitud           : Decimal(9,6);
      puntosCount        : Integer;
      categoriaDistancia : String;   // Corta, Media, Larga
      complejidadRuta    : Integer;
}
