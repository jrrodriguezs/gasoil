using { gas.app.Almacen } from '../../../db/Almacen/almacen-schema';
using { gas.app.Almacen as DbAlmacen } from '../../../db/schema';
using { gas.app.Tanque } from '../../../db/Tanques/tanques-schema';
using from '../../config-service';

extend service ConfigService with {
  @cds.redirection.target : true
  @odata.draft.enabled
  entity Almacenes as projection on DbAlmacen {
    *,
    tanques,
    coalesce((select sum(nivel_actual) from Tanque where almacen.ID = DbAlmacen.ID), 0) as actual : Double
  };
}
