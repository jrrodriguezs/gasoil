using { Ruta, PuntoCoordenada } from '../../../db/Ruta/ruta-schema';
using { Ruta as DbRuta, PuntoCoordenada as DbPuntoCoordenada } from '../../../db/schema';
using from '../../config-service';

extend service ConfigService with {
  entity Rutas as projection on DbRuta {
    *,
    (destinosCount || ' destinos') as destinosDescripcion : String
  };

  entity PuntoCoordenadas as projection on DbPuntoCoordenada;
}
