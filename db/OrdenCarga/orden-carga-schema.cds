using { managed, cuid } from '@sap/cds/common';
using { gas.app.Proveedor } from '../Proveedor/proveedor-schema';
using { gas.app.Vehiculo } from '../Vehiculo/vehiculo-schema';
using { gas.app.Chofer } from '../Chofer/chofer-schema';
using { gas.app.Tanque } from '../Tanques/tanques-schema';
using { gas.app.Almacen } from '../Almacen/almacen-schema';

namespace gas.app;

entity OrdenCarga : managed, cuid {
  fechaCarga              : DateTime;
  proveedor               : Association to Proveedor;
  tanque                  : Association to Tanque;
  placaCamionCisterna     : String;
  nombreChoferCisterna    : String;
  cedulaChoferCisterna    : String;
  carga_real              : Decimal(10,2);
  placa_vehiculo          : String;
  vehiculo                : Association to Vehiculo on vehiculo.placa = placa_vehiculo;
  cedula_chofer           : String;
  chofer                  : Association to Chofer on chofer.cedula = cedula_chofer;
  carga_facturada         : Decimal(10,2);
  observacion             : String;
  variacion               : Decimal(10,2) @cds.persistence.skip;
  porcentaje_conciliacion : Decimal(5,2) @cds.persistence.skip;
  isFirst                 : Boolean;
  almacen                 : Association to Almacen;
  to_tanques              : Composition of many TankXOrden
                              on to_tanques.orden = $self;
  precio                  : Double;
}

entity TankXOrden : cuid, managed {
  orden    : Association to OrdenCarga;
  tanque   : Association to Tanque;
  quantity : Decimal(10, 2);
}
