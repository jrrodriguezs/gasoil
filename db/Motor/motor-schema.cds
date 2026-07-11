using { managed, cuid } from '@sap/cds/common';
using { gas.common.TipoEmisiones, gas.common.VH_State } from '../common';

namespace gas.app;

entity Motor : managed, cuid {
  @mandatory modelo           : String;
  @mandatory serie            : String;
  factorEficiencia            : Double;
  torqueMax                   : Double;
  @mandatory cilindrada       : Double;
  tipoEmision                 : Association to TipoEmisiones;
  estado                      : Association to VH_State;
}
