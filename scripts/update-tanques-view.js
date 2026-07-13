const { Client } = require('pg');

const client = new Client({
  host: 'localhost',
  port: 5441,
  user: 'postgres',
  password: 'gas-db',
  database: 'gas-db'
});

const viewDDL = `CREATE OR REPLACE VIEW configservice_tanques AS SELECT
  DbTanque_0.createdAt AS createdat,
  DbTanque_0.createdBy AS createdby,
  DbTanque_0.modifiedAt AS modifiedat,
  DbTanque_0.modifiedBy AS modifiedby,
  DbTanque_0.ID AS id,
  DbTanque_0.codigo AS codigo,
  DbTanque_0.almacen_ID AS almacen_id,
  DbTanque_0.tipo_combustible AS tipo_combustible,
  DbTanque_0.capacidadTotal AS capacidadtotal,
  DbTanque_0.nivel_minimo AS nivel_minimo,
  DbTanque_0.nivel_actual AS nivel_actual,
  DbTanque_0.ultimaFechaRecarga AS ultimafecharecarga,
  DbTanque_0.descripcion AS descripcion,
  DbTanque_0.estadoTanque_code AS estadotanque_code,
  CASE
    WHEN DbTanque_0.nivel_actual <= DbTanque_0.nivel_minimo THEN 1
    WHEN DbTanque_0.nivel_actual <= (DbTanque_0.nivel_minimo * 1.5) THEN 2
    ELSE 3
  END AS nivelcriticality
FROM gas_app_Tanque AS DbTanque_0;`;

async function run() {
  try {
    await client.connect();
    console.log('Conectado a PostgreSQL');
    await client.query('DROP VIEW IF EXISTS configservice_tanques CASCADE');
    await client.query('DROP VIEW IF EXISTS "ConfigService_Tanques" CASCADE');
    console.log('Vistas anteriores eliminadas');
    await client.query(viewDDL);
    console.log('Vista configservice_tanques recreada con nivelCriticality');
  } catch (err) {
    console.error('Error:', err.message);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}

run();
