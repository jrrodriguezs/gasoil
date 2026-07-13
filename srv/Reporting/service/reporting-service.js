const cds = require('@sap/cds');
const { sincronizarHechosViaje } = require('./reporting-sync');

module.exports = cds.service.impl(async function () {
  const { ReportingService } = this.entities;

  // Poblar hechos al iniciar el servicio para que los reportes tengan datos
  try {
    const resultado = await sincronizarHechosViaje();
    console.log(`[ReportingService] Hechos sincronizados al inicio: ${resultado.sincronizados}`);
  } catch (err) {
    console.error('[ReportingService] Error sincronizando hechos al inicio:', err.message);
  }

  this.on('sincronizar', async () => {
    return sincronizarHechosViaje();
  });

  this.on('predecirConsumo', async req => {
    const { vehiculo_ID, ruta_ID, pesoTotal } = req.data;

    // Stub: modelo de regresión lineal simplificado
    const distanciaBase = 100;
    const consumoEstimado = Math.max(0,
      (distanciaBase * 0.35) + (pesoTotal * 0.002) + ((vehiculo_ID ? 1 : 0) * 0.5)
    );

    return {
      consumoEstimado: Math.round(consumoEstimado * 100) / 100,
      confianzaPct: 72.5,
      modeloUsado: 'stub-linear-regression-v1'
    };
  });

  this.on('clusterizarRutas', async () => {
    // Stub: dos clusters de ejemplo
    return [
      {
        clusterID: 1,
        descripcion: 'Rutas cortas de alto rendimiento',
        cantidadRutas: 12,
        distanciaPromedio: 65.40,
        rendimientoPromedio: 4.20
      },
      {
        clusterID: 2,
        descripcion: 'Rutas largas con carga pesada',
        cantidadRutas: 8,
        distanciaPromedio: 420.10,
        rendimientoPromedio: 2.85
      }
    ];
  });
});
