using { gas.app.Viaje } from '../../../db/Viaje/viaje-schema';
using { gas.app.Viaje as DbViaje } from '../../../db/schema';
using { gas.common.EstadoViaje } from '../../../db/common';

using from '../../config-service';

extend service ConfigService with {
  @odata.draft.enabled
  entity Viajes as projection on DbViaje {
    ID,
    vehiculo,
    chofer,
    ruta,
    fecha,
    horaSalida,
    horaLlegada,
    horaLlegadaReal,
    kilometrosRecorridos,
    minHoraSalida,
    litrosSalida,
    pesoCarga,
    consumoRealTotal,
    consumoTeoricoTotal,
    kilometrosPorLitro,
    horasPorLitro,
    estatus,
    estatusRef,
    proveedor,
    rendimientoTeorico,
    combustibleTeorico,
    costoTeorico,
    rubro,
    pesoIda,
    pesoVuelta,
    ruta.destino as nombreRuta : String,
    ruta.origen as origenRuta : String,
    ruta.latitudOrigen as origenLatitud : Decimal(9,6),
    ruta.longitudOrigen as origenLongitud : Decimal(9,6),
    origen,
    latitudOrigen,
    longitudOrigen,
    destino,
    latitudDestino,
    longitudDestino,
    (chofer.nombre || ' ' || chofer.apellido) as choferNombreCompleto : String,
    vehiculo.placa as vehiculoPlaca : String,
    vehiculo.modelo as vehiculoModelo : String,
    ruta.distanciaKm as distanciaRuta : Decimal(10,2),
    ruta.distanciaKm as distanciaTotalKm : Decimal(10,2),
    ruta.latitud as rutaLatitud : Decimal(9,6),
    ruta.longitud as rutaLongitud : Decimal(9,6),
    0 as viajesEnRuta : Integer,
    0 as viajesVehiculoEnRuta : Integer,
    0 as consumoUltimo1 : Decimal(10,2),
    0 as consumoUltimo2 : Decimal(10,2),
    0 as consumoUltimo3 : Decimal(10,2),
    0 as consumoPromedioRuta : Decimal(10,2),
    0 as consumoUltimoViajeRuta : Decimal(10,2),
    vehiculo.capacidadTotal as vehiculoCapacidadTotal : Decimal(10,2),
    vehiculo.rendimientoBase as vehiculoRendimientoBase : Decimal(5,2),
    chofer.cedula as choferCedula : String,
    chofer.telefono as choferTelefono : String,
    chofer.choferImage as choferImagen : String
  } excluding { logs } actions {
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
