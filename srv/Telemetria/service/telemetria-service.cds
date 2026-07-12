using { gas.app.Telemetria as DbTelemetria } from '../../../db/schema';
using from '../../config-service';

extend service ConfigService with {
  entity Telemetrias as projection on DbTelemetria;
}
