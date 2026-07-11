using { gas.app.OrdenCarga } from '../../../db/OrdenCarga/orden-carga-schema';
using { gas.app.OrdenCarga as DbOrdenCarga } from '../../../db/schema';
using from '../../config-service';

extend service ConfigService with {
  @odata.draft.enabled
  entity OrdenesCarga as projection on DbOrdenCarga {
    *,
    (chofer.nombre || ' ' || chofer.apellido) as choferNombreCompleto : String,
  };
}
