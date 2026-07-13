using { gas.app.Ruta as DbRuta, gas.app.PuntoCoordenada as DbPuntoCoordenada } from '../../../db/schema';
using from '../../config-service';

extend service ConfigService with {
  @cds.redirection.target : true
  entity Rutas as projection on DbRuta {
    ID,
    createdAt,
    createdBy,
    modifiedAt,
    modifiedBy,
    destino,
    origen,
    latitudOrigen,
    longitudOrigen,
    distanciaKm,
    latitud,
    longitud,
    destinosCount,
    puntos,
    nombresParadas,
    (destinosCount || ' destinos') as destinosDescripcion : String
  };

  entity PuntoCoordenadas as projection on DbPuntoCoordenada;
}
