const cds = require('@sap/cds');
(async () => {
  const db = await cds.connect.to('db');
  const tables = await db.run("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE '%draft%' ORDER BY table_name");
  console.log('Tables:', tables.map(r => r.table_name));
  for (const t of tables) {
    const cols = await db.run(`SELECT column_name FROM information_schema.columns WHERE table_name = '${t.table_name}' ORDER BY ordinal_position`);
    console.log(`\n${t.table_name}:`, cols.map(r => r.column_name).join(', '));
  }
})().catch(e => console.error(e.stack));
