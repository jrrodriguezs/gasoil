using { managed, cuid } from '@sap/cds/common';
using { gas.app.Almacen } from '../Almacen/almacen-schema';
using { gas.common.VH_State as TanqueEstado } from '../common';

namespace gas.app;

entity Tanque : managed, cuid {
  @mandatory
  @assert.unique
  codigo               : String;
  almacen              : Association to Almacen;
  tipo_combustible     : String default 'Diesel';
  capacidadTotal       : Decimal(10,2) @assert.notNull @assert.range: [1, 100000]; // Capacidad obligatoria y rango
  capacidad_tanque     : Decimal(10,2);
  nivel_minimo         : Decimal(10,2);
  nivel_actual         : Decimal(10,2);
  ultimaFechaRecarga   : Date @assert.notNull; // Fecha obligatoria
  ultima_fecha_recarga : Date;
  descripcion          : String;
  estadoTanque         : Association to TanqueEstado;
}
