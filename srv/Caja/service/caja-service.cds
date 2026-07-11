using { gas.app.Caja } from '../../../db/Caja/caja-schema';
using { gas.app.Caja as DbCaja } from '../../../db/schema';

using from '../../config-service';



extend service ConfigService with {
  @odata.draft.enabled
  entity Cajas as projection on DbCaja;
}
