process.env.PORT = '4005';

const cds = require('@sap/cds');

(async () => {
  cds.env.requires.auth = { kind: 'mocked' };
  cds.env.requires.db = {
    kind: 'sqlite',
    credentials: { url: ':memory:' }
  };

  await cds.server();
  console.log(`[test-server] CDS server started on port ${process.env.PORT}`);
})().catch(err => {
  console.error('[test-server] failed to start:', err);
  process.exit(1);
});
