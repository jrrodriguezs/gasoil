using { managed, cuid } from '@sap/cds/common';
using { gas.common.VH_State } from '../common';

namespace gas.app;

entity Transmision : managed, cuid {
  modeloDiferencial   : String;
  relacionTransmision : Double;
  factorTransmision   : Double;
  tipoEje             : String;
  capacidadCargaEje   : Double;
  estado              : Association to VH_State;
}
