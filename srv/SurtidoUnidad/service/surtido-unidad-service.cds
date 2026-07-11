using { gas.app.SurtidoUnidad } from '../../../db/SurtidoUnidad/surtido-unidad-schema';
using { gas.app.SurtidoUnidad as DbSurtidoUnidad } from '../../../db/schema';
using { gas.app.Tanque as DbTanque } from '../../../db/schema';
using from '../../config-service';

extend service ConfigService with {
  @cds.redirection.target : true
  @odata.draft.enabled
  entity SurtidosUnidad as projection on DbSurtidoUnidad {
    *
  };

  @cds.redirection.target : false
  entity TanquesDisponibles as projection on DbTanque
  where nivel_actual > 0 and estadoTanque.code = 'Operativo';
}
