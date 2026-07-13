using { managed, cuid } from '@sap/cds/common';

namespace gas.app;

entity Ruta : managed, cuid {
  @mandatory destino : String; // Destino de la ruta
  @mandatory origen  : String default 'Maracaibo'; // Origen de la ruta
  latitudOrigen      : Decimal(9,6); // Latitud del origen
  longitudOrigen     : Decimal(9,6); // Longitud del origen
  @mandatory distanciaKm : Decimal(10,2);
  latitud       : Decimal(9,6); // Latitud del destino
  longitud      : Decimal(9,6); // Longitud del destino
  destinosCount : Integer;
  puntos        : Composition of many PuntoCoordenada on puntos.ruta = $self;
  nombresParadas : String;
}

entity PuntoCoordenada : managed {
  key ID      : UUID;
  orden       : Integer; // Orden físico del punto dentro de la ruta (0 = origen Maracaibo)
  latitud     : Decimal(9,6);
  longitud    : Decimal(9,6);
  descripcion : String;
  ruta        : Association to Ruta;
}
