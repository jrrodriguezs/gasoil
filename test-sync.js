const cds = require('@sap/cds');
const { sincronizarHechosViaje } = require('./srv/Reporting/service/reporting-sync');

(async () => {
  cds.env.requires.db = { kind: 'sqlite', credentials: { url: ':memory:' } };
  const db = await cds.connect.to('db');
  await cds.deploy('*').to(db);

  console.log('Mock data loaded. Viajes sample:');
  const viajes = await cds.run(SELECT.from('gas.app.Viaje'));
  console.log('count:', viajes.length);

  const resultado = await sincronizarHechosViaje();
  console.log('Sync result:', resultado);

  const hechos = await cds.run(SELECT.from('gas.reporting.HechoViaje'));
  console.log('Hechos count:', hechos.length);
  if (hechos.length) console.log('First hecho:', JSON.stringify(hechos[0], null, 2).slice(0, 800));

  const agg = await cds.run(SELECT.from('gas.reporting.V_AggMensual'));
  console.log('AggMensual count:', agg.length);
  if (agg.length) console.log('AggMensual first:', agg[0]);

  process.exit(0);
})().catch(err => {
  console.error(err);
  process.exit(1);
});
