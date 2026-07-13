const { Client } = require('pg');

const client = new Client({
  host: 'localhost',
  port: 5441,
  user: 'postgres',
  password: 'gas-db',
  database: 'gas-db'
});

async function run() {
  try {
    await client.connect();
    await client.query('DROP VIEW IF EXISTS "ConfigService_Viajes" CASCADE');
    console.log('Vista ConfigService_Viajes eliminada');
  } catch (err) {
    console.error('Error:', err.message);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}

run();
