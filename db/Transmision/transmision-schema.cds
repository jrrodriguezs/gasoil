using { managed, cuid } from '@sap/cds/common';

namespace gas.app;

entity Transmision : managed, cuid {
  modeloDiferencial   : String;
  relacionTransmision : Double;
  factorTransmision   : Double;
  tipoEje             : String;
  capacidadCargaEje   : Double;
}
