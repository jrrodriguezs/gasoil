const { Client } = require('pg');

const client = new Client({
  host: 'localhost',
  port: 5441,
  user: 'postgres',
  password: 'gas-db',
  database: 'gas-db'
});

const views = [
  {
    name: 'ConfigService_PerformanceAvg',
    ddl: `CREATE OR REPLACE VIEW ConfigService_PerformanceAvg AS SELECT
  avg(Viajes_0.kilometrosPorLitro) AS rendimientoPromedioGeneral,
  count(Viajes_0.ID) AS totalViajes
FROM ConfigService_Viajes AS Viajes_0;`
  },
  {
    name: 'ConfigService_PerformancePerRoute',
    ddl: `CREATE OR REPLACE VIEW ConfigService_PerformancePerRoute AS SELECT
  avg(Viajes_0.kilometrosPorLitro) AS rendimientoPromedio,
  ruta_1.destino AS ruta
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN gas_app_Ruta AS ruta_1 ON Viajes_0.ruta_ID = ruta_1.ID)
GROUP BY ruta_1.destino;`
  },
  {
    name: 'ConfigService_PerformancePerWeight',
    ddl: `CREATE OR REPLACE VIEW ConfigService_PerformancePerWeight AS SELECT
  avg(Viajes_0.kilometrosPorLitro) AS rendimientoPromedio,
  CASE WHEN Viajes_0.pesoCarga >= 0 AND Viajes_0.pesoCarga <= 10000 THEN '0-10000 kg' WHEN Viajes_0.pesoCarga >= 10000 AND Viajes_0.pesoCarga <= 20000 THEN '10000-20000 kg' WHEN Viajes_0.pesoCarga >= 20000 AND Viajes_0.pesoCarga <= 30000 THEN '20000-30000 kg' ELSE '30000+ kg' END AS rangoPeso
FROM ConfigService_Viajes AS Viajes_0
GROUP BY CASE WHEN Viajes_0.pesoCarga >= 0 AND Viajes_0.pesoCarga <= 10000 THEN '0-10000 kg' WHEN Viajes_0.pesoCarga >= 10000 AND Viajes_0.pesoCarga <= 20000 THEN '10000-20000 kg' WHEN Viajes_0.pesoCarga >= 20000 AND Viajes_0.pesoCarga <= 30000 THEN '20000-30000 kg' ELSE '30000+ kg' END
ORDER BY rendimientoPromedio DESC;`
  },
  {
    name: 'ConfigService_PerformancePlannedVSReal',
    ddl: `CREATE OR REPLACE VIEW ConfigService_PerformancePlannedVSReal AS SELECT
  'ABC' AS id,
  avg(Viajes_0.kilometrosPorLitro) AS rendimientoPromedioReal,
  avg(vehiculo_1.rendimientoBase) AS rendimientoPromedioTeorico,
  CASE WHEN avg(vehiculo_1.rendimientoBase) = 0 OR avg(vehiculo_1.rendimientoBase) IS NULL THEN 0 ELSE round(((avg(Viajes_0.kilometrosPorLitro) - avg(vehiculo_1.rendimientoBase)) / avg(vehiculo_1.rendimientoBase)) * 100, 2) END AS variacionPorcentual
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN ConfigService_Vehiculos AS vehiculo_1 ON Viajes_0.vehiculo_ID = vehiculo_1.ID);`
  },
  {
    name: 'ConfigService_DriverPerformance',
    ddl: `CREATE OR REPLACE VIEW ConfigService_DriverPerformance AS SELECT
  Viajes_0.chofer_ID AS chofer_ID,
  avg(Viajes_0.kilometrosPorLitro) AS rendimientoPromedio
FROM ConfigService_Viajes AS Viajes_0
GROUP BY Viajes_0.chofer_ID;`
  },
  {
    name: 'ConfigService_PerformancePerRubro',
    ddl: `CREATE OR REPLACE VIEW ConfigService_PerformancePerRubro AS SELECT
  CASE WHEN rubro_1.name IS NULL THEN 'No especificado' ELSE rubro_1.name END AS rubro,
  count(Viajes_0.ID) AS cantidad,
  avg(Viajes_0.kilometrosPorLitro) AS rendimiento,
  max(Viajes_0.kilometrosPorLitro) AS rendimientoMaximo
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN gas_app_Rubros AS rubro_1 ON Viajes_0.rubro_ID = rubro_1.ID)
GROUP BY CASE WHEN rubro_1.name IS NULL THEN 'No especificado' ELSE rubro_1.name END;`
  },
  {
    name: 'ConfigService_ViajesPorRutaSum',
    ddl: `CREATE OR REPLACE VIEW ConfigService_ViajesPorRutaSum AS SELECT
  ruta_1.destino AS ruta,
  'Viajes' AS unitViajes,
  'km' AS unitKm,
  count(Viajes_0.ID) AS cantidadViajes,
  sum(ruta_1.distanciaKm) AS distanciaRecorrida
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN gas_app_Ruta AS ruta_1 ON Viajes_0.ruta_ID = ruta_1.ID)
GROUP BY ruta_1.destino;`
  },
  {
    name: 'ConfigService_ViajesPorRutaTiempo',
    ddl: `CREATE OR REPLACE VIEW ConfigService_ViajesPorRutaTiempo AS SELECT
  ruta_1.destino AS ruta,
  count(Viajes_0.ID) AS cantidadViajes,
  sum(ruta_1.distanciaKm) AS distanciaRecorrida,
  SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4) AS anio,
  SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) AS mes2
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN gas_app_Ruta AS ruta_1 ON Viajes_0.ruta_ID = ruta_1.ID)
GROUP BY ruta_1.destino, SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4), SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2);`
  },
  {
    name: 'ConfigService_ViajesPorMes',
    ddl: `CREATE OR REPLACE VIEW ConfigService_ViajesPorMes AS SELECT
  count(Viajes_0.ID) AS cantidadViajes,
  sum(ruta_1.distanciaKm) AS distanciaRecorrida,
  SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4) AS anio,
  SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) AS mes,
  CASE WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '01' THEN 'Enero' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '02' THEN 'Febrero' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '03' THEN 'Marzo' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '04' THEN 'Abril' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '05' THEN 'Mayo' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '06' THEN 'Junio' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '07' THEN 'Julio' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '08' THEN 'Agosto' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '09' THEN 'Septiembre' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '10' THEN 'Octubre' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '11' THEN 'Noviembre' ELSE 'Diciembre' END AS nombreMes,
  SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4) || ' ' || (CASE WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '01' THEN 'Enero' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '02' THEN 'Febrero' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '03' THEN 'Marzo' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '04' THEN 'Abril' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '05' THEN 'Mayo' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '06' THEN 'Junio' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '07' THEN 'Julio' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '08' THEN 'Agosto' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '09' THEN 'Septiembre' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '10' THEN 'Octubre' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '11' THEN 'Noviembre' ELSE 'Diciembre' END) AS fechaText
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN gas_app_Ruta AS ruta_1 ON Viajes_0.ruta_ID = ruta_1.ID)
GROUP BY SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4), SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2), CASE WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '01' THEN 'Enero' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '02' THEN 'Febrero' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '03' THEN 'Marzo' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '04' THEN 'Abril' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '05' THEN 'Mayo' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '06' THEN 'Junio' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '07' THEN 'Julio' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '08' THEN 'Agosto' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '09' THEN 'Septiembre' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '10' THEN 'Octubre' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '11' THEN 'Noviembre' ELSE 'Diciembre' END, SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4) || ' ' || (CASE WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '01' THEN 'Enero' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '02' THEN 'Febrero' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '03' THEN 'Marzo' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '04' THEN 'Abril' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '05' THEN 'Mayo' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '06' THEN 'Junio' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '07' THEN 'Julio' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '08' THEN 'Agosto' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '09' THEN 'Septiembre' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '10' THEN 'Octubre' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) = '11' THEN 'Noviembre' ELSE 'Diciembre' END)
ORDER BY SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4), SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2);`
  },
  {
    name: 'ConfigService_ViajesPorAnio',
    ddl: `CREATE OR REPLACE VIEW ConfigService_ViajesPorAnio AS SELECT
  count(Viajes_0.ID) AS cantidadViajes,
  sum(ruta_1.distanciaKm) AS distanciaRecorrida,
  SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4) AS anio
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN gas_app_Ruta AS ruta_1 ON Viajes_0.ruta_ID = ruta_1.ID)
GROUP BY SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4)
ORDER BY SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4);`
  },
  {
    name: 'ConfigService_ViajesPorTrimestre',
    ddl: `CREATE OR REPLACE VIEW ConfigService_ViajesPorTrimestre AS SELECT
  count(Viajes_0.ID) AS cantidadViajes,
  sum(ruta_1.distanciaKm) AS distanciaRecorrida,
  SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4) AS anio,
  CASE WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('01', '02', '03') THEN 'Q1' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('04', '05', '06') THEN 'Q2' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('07', '08', '09') THEN 'Q3' ELSE 'Q4' END AS trimestre,
  SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4) || ' ' || (CASE WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('01', '02', '03') THEN 'Q1' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('04', '05', '06') THEN 'Q2' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('07', '08', '09') THEN 'Q3' ELSE 'Q4' END) AS fechaText
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN gas_app_Ruta AS ruta_1 ON Viajes_0.ruta_ID = ruta_1.ID)
GROUP BY SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4), CASE WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('01', '02', '03') THEN 'Q1' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('04', '05', '06') THEN 'Q2' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('07', '08', '09') THEN 'Q3' ELSE 'Q4' END, SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4) || ' ' || (CASE WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('01', '02', '03') THEN 'Q1' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('04', '05', '06') THEN 'Q2' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('07', '08', '09') THEN 'Q3' ELSE 'Q4' END)
ORDER BY SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 1, 4) || ' ' || (CASE WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('01', '02', '03') THEN 'Q1' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('04', '05', '06') THEN 'Q2' WHEN SUBSTR(CAST(Viajes_0.fecha AS VARCHAR(255)), 6, 2) IN ('07', '08', '09') THEN 'Q3' ELSE 'Q4' END);`
  },
  {
    name: 'ConfigService_CostoCombustiblePromedio',
    ddl: `CREATE OR REPLACE VIEW ConfigService_CostoCombustiblePromedio AS SELECT
  'ABC' AS id,
  sum(Viajes_0.consumoRealTotal) AS totalCombustibleConsumido,
  sum(Viajes_0.kilometrosRecorridos) AS totalKilometrosRecorridos,
  (SELECT
      avg(UltimoPrecioCombustibleProveedor_1.ultimoPrecio)
    FROM ConfigService_UltimoPrecioCombustibleProveedor AS UltimoPrecioCombustibleProveedor_1) AS precioPromedioCombustible,
  sum(Viajes_0.consumoRealTotal) * (SELECT
      avg(UltimoPrecioCombustibleProveedor_1.ultimoPrecio)
    FROM ConfigService_UltimoPrecioCombustibleProveedor AS UltimoPrecioCombustibleProveedor_1) AS costoCombustible,
  (sum(Viajes_0.consumoRealTotal) * (SELECT
      avg(UltimoPrecioCombustibleProveedor_1.ultimoPrecio)
    FROM ConfigService_UltimoPrecioCombustibleProveedor AS UltimoPrecioCombustibleProveedor_1)) / sum(Viajes_0.consumoRealTotal) AS costoPromedioPorLitro,
  CASE WHEN sum(Viajes_0.kilometrosRecorridos) = 0 OR sum(Viajes_0.kilometrosRecorridos) IS NULL THEN 0 ELSE round((sum(Viajes_0.consumoRealTotal) * (SELECT
      avg(UltimoPrecioCombustibleProveedor_1.ultimoPrecio)
    FROM ConfigService_UltimoPrecioCombustibleProveedor AS UltimoPrecioCombustibleProveedor_1)) / sum(Viajes_0.kilometrosRecorridos), 2) END AS costoPorKm
FROM ConfigService_Viajes AS Viajes_0;`
  },
  {
    name: 'ConfigService_DriverRating',
    ddl: `CREATE OR REPLACE VIEW ConfigService_DriverRating AS SELECT
  'ABC' AS id,
  avg(DriverPerformance_0.rendimientoPromedio) AS rendimientoPromedioConductores,
  CASE WHEN avg(DriverPerformance_0.rendimientoPromedio) IS NULL THEN 0 WHEN avg(DriverPerformance_0.rendimientoPromedio) * 25 > 100 THEN 100 ELSE round(avg(DriverPerformance_0.rendimientoPromedio) * 25, 2) END AS calificacionPromedioConductores
FROM ConfigService_DriverPerformance AS DriverPerformance_0;`
  }
];

async function run() {
  try {
    await client.connect();
    console.log('Conectado a PostgreSQL');
    for (const view of views) {
      try {
        await client.query(view.ddl);
        console.log('✓', view.name);
      } catch (err) {
        console.error('✗', view.name, ':', err.message);
      }
    }
  } catch (err) {
    console.error('Error de conexión:', err.message);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}

run();
