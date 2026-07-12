/**
 * srv/server.js
 * Entry point customizado para GAS-APP.
 *
 * FIX-024: Carga las credenciales de PostgreSQL desde variables de entorno
 * (archivo .env) en lugar de tenerlas hardcodeadas en package.json.
 *
 * CDS (Cloud Application Programming Model) detecta automáticamente este
 * archivo y lo carga antes de arrancar el servidor.
 */

const cds = require('@sap/cds');
require('dotenv').config(); // Carga variables desde .env (ya incluido en CAP, pero explícito por seguridad)

// ---------------------------------------------------------------------------
// Configuración de base de datos para entorno TEST (desarrollo local)
// ---------------------------------------------------------------------------
cds.env.requires.test = {
  db: {
    kind: 'postgres',
    impl: '@cap-js/postgres',
    credentials: {
      host:     process.env.GAS_DB_HOST     || 'localhost',
      port:     process.env.GAS_DB_PORT     || 5441,
      user:     process.env.GAS_DB_USER     || 'postgres',
      password: process.env.GAS_DB_PASSWORD || 'gas-db',
      db:       process.env.GAS_DB_NAME     || 'gas-db'
    }
  }
};

// ---------------------------------------------------------------------------
// Configuración de base de datos para entorno PROD
// ---------------------------------------------------------------------------
cds.env.requires.prod = {
  db: {
    kind: 'postgres',
    impl: '@cap-js/postgres',
    credentials: {
      host:     process.env.GAS_DB_PROD_HOST     || 'gas-app-db',
      port:     process.env.GAS_DB_PROD_PORT     || 5432,
      user:     process.env.GAS_DB_PROD_USER     || 'postgres',
      password: process.env.GAS_DB_PROD_PASSWORD || 'gasapptandem123.',
      db:       process.env.GAS_DB_PROD_NAME     || 'gas-db'
    }
  }
};

// ---------------------------------------------------------------------------
// Exporta el servidor CDS estándar para que CDS lo arranque
// ---------------------------------------------------------------------------
module.exports = cds.server;
