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
    console.log('Connected to PostgreSQL');
    const res = await client.query(`
      SELECT column_name, data_type, numeric_precision, numeric_scale
      FROM information_schema.columns
      WHERE table_name = 'configservice_viajes_drafts'
      ORDER BY ordinal_position;
    `);
    console.log('Columns in ConfigService_Viajes_drafts:');
    console.table(res.rows);

    const col = res.rows.find(r => r.column_name.toLowerCase() === 'distanciatotalkm');
    if (!col) {
      console.log('Adding missing distanciaTotalKm column...');
      await client.query('ALTER TABLE ConfigService_Viajes_drafts ADD COLUMN distanciaTotalKm DECIMAL(10,2) NULL');
      console.log('Column added');
    } else {
      console.log('distanciaTotalKm already exists');
    }
  } catch (err) {
    console.error('Error:', err.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

run();
