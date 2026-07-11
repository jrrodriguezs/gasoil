using { gas.app.Chofer } from '../../../db/Chofer/chofer-schema';
//using { gas.app.Chofer as DbChofer } from '../../../db/schema';
//using { gas.app.Viaje } from '../../../db/Viaje/viaje-schema';
using from '../../config-service';


extend service ConfigService with {
   @odata.draft.enabled
  entity Choferes as projection on Chofer {
    *,
    (nombre || ' ' || apellido) as nombreCompleto : String
  };
    
    
  
}
