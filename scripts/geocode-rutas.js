/**
 * Script para geocodificar los destinos de Rutas y actualizar
 * origen, latitud/longitud de origen y latitud/longitud de destino
 * tanto en PostgreSQL como en el CSV de origen.
 *
 * Origen fijo: Maracaibo (10.547027, -71.636306)
 *
 * Uso:
 *   node scripts/geocode-rutas.js
 */

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY;
if (!GOOGLE_MAPS_API_KEY) {
  console.error('Falta GOOGLE_MAPS_API_KEY en .env');
  process.exit(1);
}

const CSV_PATH = path.join(__dirname, '..', 'db', 'data', 'gas.app-Ruta.csv');

const ORIGEN = 'Maracaibo';
const LATITUD_ORIGEN = 10.547027;
const LONGITUD_ORIGEN = -71.636306;

async function geocodeAddress(address) {
  const query = encodeURIComponent(address + ', Venezuela');
  const url = `https://maps.googleapis.com/maps/api/geocode/json?address=${query}&key=${GOOGLE_MAPS_API_KEY}`;
  const response = await fetch(url);
  const data = await response.json();
  if (data.status !== 'OK' || !data.results || !data.results.length) {
    throw new Error(`Geocodificación fallida para "${address}": ${data.status}`);
  }
  const loc = data.results[0].geometry.location;
  return { lat: loc.lat, lng: loc.lng };
}

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
  const client = new Client({
    host: process.env.GAS_DB_HOST || 'localhost',
    port: Number(process.env.GAS_DB_PORT || 5441),
    user: process.env.GAS_DB_USER || 'postgres',
    password: process.env.GAS_DB_PASSWORD || 'gas-db',
    database: process.env.GAS_DB_NAME || 'gas-db'
  });

  await client.connect();

  try {
    // 1. Actualizar origen fijo en todas las rutas
    await client.query(
      `UPDATE gas_app_ruta SET origen = $1, latitudorigen = $2, longitudorigen = $3`,
      [ORIGEN, LATITUD_ORIGEN, LONGITUD_ORIGEN]
    );
    console.log(`Origen fijo aplicado a todas las rutas: ${ORIGEN} (${LATITUD_ORIGEN}, ${LONGITUD_ORIGEN})`);

    // 2. Geocodificar destinos
    const { rows: rutas } = await client.query(
      `SELECT id, destino, latitud, longitud FROM gas_app_ruta ORDER BY destino`
    );

    console.log(`Total de rutas encontradas: ${rutas.length}`);

    const coordenadasPorDestino = {};

    for (const ruta of rutas) {
      try {
        const coords = await geocodeAddress(ruta.destino);
        coordenadasPorDestino[ruta.destino] = coords;
        await client.query(
          `UPDATE gas_app_ruta SET latitud = $1, longitud = $2 WHERE id = $3`,
          [coords.lat, coords.lng, ruta.id]
        );
        console.log(`✓ ${ruta.destino} → ${coords.lat}, ${coords.lng}`);
      } catch (err) {
        console.error(`✗ ${ruta.destino}: ${err.message}`);
      }
      await sleep(120); // respetar cuota
    }

    // 3. Actualizar CSV de origen
    const csvLines = fs.readFileSync(CSV_PATH, 'utf8').split(/\r?\n/);
    const header = csvLines[0];
    const headers = header.split(',');

    const idxDestino = headers.indexOf('destino');
    const idxOrigen = headers.indexOf('origen');
    const idxLatOrigen = headers.indexOf('latitudOrigen');
    const idxLngOrigen = headers.indexOf('longitudOrigen');
    const idxLat = headers.indexOf('latitud');
    const idxLng = headers.indexOf('longitud');
    const idxDistancia = headers.indexOf('distanciaKm');

    if (idxDestino === -1 || idxOrigen === -1 || idxLatOrigen === -1 || idxLngOrigen === -1 || idxLat === -1 || idxLng === -1) {
      console.warn('No se encontraron todas las columnas esperadas en el CSV; no se actualizó.');
      console.warn('Header actual:', header);
      return;
    }

    const updatedLines = csvLines.map((line, index) => {
      if (index === 0 || !line.trim()) return line;
      const parts = line.split(',');
      const destino = parts[idxDestino];

      parts[idxOrigen] = ORIGEN;
      parts[idxLatOrigen] = LATITUD_ORIGEN;
      parts[idxLngOrigen] = LONGITUD_ORIGEN;

      if (coordenadasPorDestino[destino]) {
        const coords = coordenadasPorDestino[destino];
        parts[idxLat] = coords.lat;
        parts[idxLng] = coords.lng;
      }
      return parts.join(',');
    });

    fs.writeFileSync(CSV_PATH, updatedLines.join('\n') + '\n', 'utf8');
    console.log(`CSV actualizado: ${CSV_PATH}`);

  } finally {
    await client.end();
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
