using { gas.app.Motor } from '../../../db/Motor/motor-schema';
using { gas.app.Motor as DbMotor } from '../../../db/schema';
using from '../../config-service';

extend service ConfigService with {
  @odata.draft.enabled
  entity Motores as projection on DbMotor;
}
