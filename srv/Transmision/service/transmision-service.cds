using { gas.app.Transmision } from '../../../db/Transmision/transmision-schema';
using { gas.app.Transmision as DbTransmision } from '../../../db/schema';
using from '../../config-service';

extend service ConfigService with {
  @odata.draft.enabled
  entity Transmisiones as projection on DbTransmision;
}
