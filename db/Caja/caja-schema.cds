using { managed, cuid } from '@sap/cds/common';

namespace gas.app;

entity Caja : managed, cuid {
  @mandatory modeloCaja        : String;
  @mandatory numeroVelocidades : Integer;
  @mandatory factorTransmision : Double;
}