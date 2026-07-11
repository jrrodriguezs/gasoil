using { gas.app.Viaje } from '../../../db/Viaje/viaje-schema';
using { gas.app.Viaje as DbViaje } from '../../../db/schema';
using { gas.common.EstadoViaje } from '../../../db/common';
using from '../../config-service';

extend service ConfigService with {
  @odata.draft.enabled
  entity Viajes as projection on DbViaje {
    *,
    ruta.descripcion as nombreRuta : String,
    (chofer.nombre || ' ' || chofer.apellido) as choferNombreCompleto : String
  } actions {
     action changeStatus()
  };

  entity EstadoViajes as projection on EstadoViaje;

  
}

/* annotate ConfigService.Viajes with {
  estatus @assert.message : 'No puede colocar un viaje en estatus Cancelado o Finalizado.'
          @assert : (case
    when estatus = 'Cancelado' then true
    when estatus = 'Finalizado' then true
    else false
  end);


};

 */