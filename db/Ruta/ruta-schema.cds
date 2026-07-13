using { managed, cuid } from '@sap/cds/common';

namespace gas.app;

entity Ruta : managed, cuid {
  @mandatory descripcion : String; // Origen - Destino
  @mandatory distanciaKm : Decimal(10,2);
  latitud       : Decimal(9,6);
  longitud      : Decimal(9,6);
  destinosCount : Integer;
  puntos        : Composition of many PuntoCoordenada on puntos.ruta = $self;
}

entity PuntoCoordenada : managed {
  key ID      : UUID;
  latitud     : Decimal(9,6);
  longitud    : Decimal(9,6);
  descripcion : String;
  ruta        : Association to Ruta;
}
