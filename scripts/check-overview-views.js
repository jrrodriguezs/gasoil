const { Client } = require('pg');

const client = new Client({
  host: 'localhost',
  port: 5441,
  user: 'postgres',
  password: 'gas-db',
  database: 'gas-db'
});

const expectedViews = [
  'configservice_performacepervehicle',
  'configservice_performanceavg',
  'configservice_performancebymodel',
  'configservice_tankcapacity',
  'configservice_performanceperroute',
  'configservice_performanceperweight',
  'configservice_vehicleperstatus',
  'configservice_tankperstatus',
  'configservice_costocombustiblepromedio',
  'configservice_ultimopreciocombustibleproveedor',
  'configservice_tankcritical',
  'configservice_performanceplannedvsreal',
  'configservice_driverperformance',
  'configservice_driverrating',
  'configservice_performacepermotor',
  'configservice_performacepertransmision',
  'configservice_performacepercaja',
  'configservice_performanceperrubro',
  'configservice_viajesporrutasum',
  'configservice_viajesporrutatiempo',
  'configservice_viajespormes',
  'configservice_viajesporanio',
  'configservice_viajesportrimestre'
];

async function run() {
  try {
    await client.connect();
    const res = await client.query(`
      SELECT table_name
      FROM information_schema.views
      WHERE table_schema = 'public'
        AND table_name LIKE 'configservice_%'
      ORDER BY table_name
    `);
    const existing = new Set(res.rows.map(r => r.table_name.toLowerCase()));
    console.log('Vistas existentes (configservice_*):');
    existing.forEach(v => console.log('  -', v));
    console.log('\nVistas faltantes:');
    const missing = expectedViews.filter(v => !existing.has(v));
    if (missing.length === 0) {
      console.log('  Ninguna');
    } else {
      missing.forEach(v => console.log('  -', v));
    }
  } catch (err) {
    console.error('Error:', err.message);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}

run();
