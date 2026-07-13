using { managed, cuid } from '@sap/cds/common';
using { gas.app.Almacen } from '../Almacen/almacen-schema';
using { gas.app.OrdenCarga } from '../OrdenCarga/orden-carga-schema';
using { gas.common.VH_State as TanqueEstado } from '../common';

namespace gas.app;

entity Tanque : managed, cuid {
  @mandatory
  @assert.unique
  codigo               : String;
  almacen              : Association to Almacen @mandatory;
  tipo_combustible     : String default 'Diesel';
  capacidadTotal       : Decimal(10,2) @assert.notNull @assert.range: [1, 100000]; // Capacidad obligatoria y rango
  nivel_minimo         : Decimal(10,2);
  nivel_actual         : Decimal(10,2);
  ultimaFechaRecarga   : DateTime @assert.notNull; // Fecha obligatoria
  descripcion          : String;
  estadoTanque         : Association to TanqueEstado;
  ordenesCarga         : Association to many OrdenCarga on ordenesCarga.tanque = $self;
}
