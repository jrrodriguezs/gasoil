using { managed, cuid } from '@sap/cds/common';
using { gas.app.Vehiculo } from '../Vehiculo/vehiculo-schema';
using { gas.app.Almacen } from '../Almacen/almacen-schema';
using { gas.app.Tanque } from '../Tanques/tanques-schema';
using { gas.app.Proveedor } from '../Proveedor/proveedor-schema';
using { gas.app.OrdenCarga } from '../OrdenCarga/orden-carga-schema';

namespace gas.app;

entity SurtidoUnidad : managed, cuid {
  @mandatory fechaCarga               : DateTime;
  @mandatory vehiculo                 : Association to Vehiculo;
  tanque                   : Association to Tanque;
  @mandatory carga_real               : Decimal(10,2);
  volumenPrevioVehiculo    : Decimal(10,2);
  volumen_actual_vehiculo  : Decimal(10,2);
  @mandatory responsable              : String;
  cargaExterna             : Boolean default false;
  nombreEstacionServicio   : String;
  precioCombustible        : Decimal(10,2);
  almacen                  : Association to Almacen;
  proveedor                : Association to Proveedor;
  ordenCarga               : Association to OrdenCarga;
}
