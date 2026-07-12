using { managed, cuid } from '@sap/cds/common';
using { gas.common.VH_State } from '../common';

namespace gas.app;

entity Caja : managed, cuid {
  @mandatory modeloCaja        : String;
  @mandatory numeroVelocidades : Integer;
  @mandatory factorTransmision : Double;
  estado                      : Association to VH_State;
}