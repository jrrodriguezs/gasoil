const { Client } = require('pg');

const client = new Client({
  host: 'localhost',
  port: 5441,
  user: 'postgres',
  password: 'gas-db',
  database: 'gas-db'
});

const viewDDL = `CREATE OR REPLACE VIEW configservice_viajes AS SELECT
  DbViaje_0.ID AS id,
  DbViaje_0.vehiculo_ID AS vehiculo_id,
  DbViaje_0.chofer_ID AS chofer_id,
  DbViaje_0.ruta_ID AS ruta_id,
  DbViaje_0.fecha AS fecha,
  DbViaje_0.horaSalida AS horasalida,
  DbViaje_0.horaLlegada AS horallegada,
  DbViaje_0.horaLlegadaReal AS horallegadareal,
  DbViaje_0.kilometrosRecorridos AS kilometrosrecorridos,
  DbViaje_0.minHoraSalida AS minhorasalida,
  DbViaje_0.litrosSalida AS litrossalida,
  DbViaje_0.pesoCarga AS pesocarga,
  DbViaje_0.consumoRealTotal AS consumorealtotal,
  DbViaje_0.consumoTeoricoTotal AS consumoteoricototal,
  DbViaje_0.kilometrosPorLitro AS kilometrosporlitro,
  DbViaje_0.horasPorLitro AS horasporlitro,
  DbViaje_0.estatus AS estatus,
  DbViaje_0.proveedor_ID AS proveedor_id,
  DbViaje_0.rendimientoTeorico AS rendimientoteorico,
  DbViaje_0.combustibleTeorico AS combustibleteorico,
  DbViaje_0.costoTeorico AS costoteorico,
  DbViaje_0.rubro_ID AS rubro_id,
  DbViaje_0.pesoIda AS pesoida,
  DbViaje_0.pesoVuelta AS pesovuelta,
  ruta_3.destino AS nombreruta,
  ruta_3.origen AS origenruta,
  ruta_3.latitudOrigen AS origenlatitud,
  ruta_3.longitudOrigen AS origenlongitud,
  DbViaje_0.origen AS origen,
  DbViaje_0.latitudOrigen AS latitudorigen,
  DbViaje_0.longitudOrigen AS longitudorigen,
  DbViaje_0.destino AS destino,
  DbViaje_0.latitudDestino AS latituddestino,
  DbViaje_0.longitudDestino AS longituddestino,
  chofer_2.nombre || ' ' || chofer_2.apellido AS chofernombrecompleto,
  vehiculo_1.placa AS vehiculoplaca,
  vehiculo_1.modelo AS vehiculomodelo,
  ruta_3.distanciaKm AS distanciaruta,
  ruta_3.distanciaKm AS distanciatotalkm,
  ruta_3.latitud AS rutalatitud,
  ruta_3.longitud AS rutalongitud,
  0 AS viajesenruta,
  0 AS viajesvehiculoenruta,
  0 AS consumoultimo1,
  0 AS consumoultimo2,
  0 AS consumoultimo3,
  0 AS consumopromedioruta,
  0 AS consumoultimoviajeruta,
  vehiculo_1.capacidadTotal AS vehiculocapacidadtotal,
  vehiculo_1.rendimientoBase AS vehiculorendimientobase,
  chofer_2.cedula AS chofercedula,
  chofer_2.telefono AS chofertelefono,
  chofer_2.choferImage AS choferimagen
FROM (((gas_app_Viaje AS DbViaje_0 LEFT JOIN gas_app_Vehiculo AS vehiculo_1 ON DbViaje_0.vehiculo_ID = vehiculo_1.ID) LEFT JOIN gas_app_Chofer AS chofer_2 ON DbViaje_0.chofer_ID = chofer_2.ID) LEFT JOIN gas_app_Ruta AS ruta_3 ON DbViaje_0.ruta_ID = ruta_3.ID);`;

async function run() {
  try {
    await client.connect();
    console.log('Conectado a PostgreSQL');
    await client.query('DROP VIEW IF EXISTS configservice_viajes CASCADE');
    await client.query('DROP VIEW IF EXISTS "ConfigService_Viajes" CASCADE');
    console.log('Vistas anteriores eliminadas');
    await client.query(viewDDL);
    console.log('Vista configservice_viajes recreada con distanciaTotalKm');
  } catch (err) {
    console.error('Error:', err.message);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}

run();
