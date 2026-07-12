const cds = require("@sap/cds");
const { SELECT, UPDATE } = require("@sap/cds/lib/ql/cds-ql");

/**
 * Calcula la distancia entre dos puntos geográficos usando la fórmula de Haversine.
 * @param {number} lat1 - Latitud punto 1
 * @param {number} lon1 - Longitud punto 1
 * @param {number} lat2 - Latitud punto 2
 * @param {number} lon2 - Longitud punto 2
 * @returns {number} Distancia en kilómetros
 */
function haversineDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Radio de la Tierra en km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

module.exports = async (srv) => {
    const { Telemetrias, Viajes } = cds.entities('ConfigService');

    /**
     * Helper: recalcula kilometrosRecorridos y consumoRealTotal
     * para un viaje basado en sus registros de telemetría.
     */
    async function recalcularViaje(viajeId) {
        if (!viajeId) return;

        // Obtener todas las telemetrías del viaje ordenadas por timestamp
        const telemetrias = await SELECT.from(Telemetrias)
            .where({ viaje_ID: viajeId })
            .orderBy({ timestamp: 'asc' });

        if (!telemetrias || telemetrias.length === 0) return;

        // ── Calcular consumoRealTotal ──
        // Diferencia entre nivelCombustible máximo y mínimo del viaje
        const niveles = telemetrias
            .map(t => parseFloat(t.nivelCombustible))
            .filter(n => !isNaN(n));
        let consumoRealTotal = 0;
        if (niveles.length > 0) {
            const maxNivel = Math.max(...niveles);
            const minNivel = Math.min(...niveles);
            consumoRealTotal = maxNivel - minNivel;
            if (consumoRealTotal < 0) consumoRealTotal = 0;
        }

        // ── Calcular kilometrosRecorridos ──
        // Suma de distancias Haversine entre puntos consecutivos con velocidad > 5 km/h
        let kilometrosRecorridos = 0;
        for (let i = 1; i < telemetrias.length; i++) {
            const prev = telemetrias[i - 1];
            const curr = telemetrias[i];
            const velocidad = parseFloat(curr.velocidad);
            const lat1 = parseFloat(prev.latitud);
            const lon1 = parseFloat(prev.longitud);
            const lat2 = parseFloat(curr.latitud);
            const lon2 = parseFloat(curr.longitud);

            if (!isNaN(velocidad) && velocidad > 5 &&
                !isNaN(lat1) && !isNaN(lon1) && !isNaN(lat2) && !isNaN(lon2)) {
                kilometrosRecorridos += haversineDistance(lat1, lon1, lat2, lon2);
            }
        }

        // ── Actualizar el viaje ──
        await UPDATE(Viajes).set({
            consumoRealTotal: parseFloat(consumoRealTotal.toFixed(2)),
            kilometrosRecorridos: parseFloat(kilometrosRecorridos.toFixed(2))
        }).where({ ID: viajeId });
    }

    // ── Validar que el viaje exista antes de CREATE/UPDATE ──
    srv.before("CREATE", Telemetrias, async (req) => {
        const viajeId = req.data?.viaje_ID;
        if (!viajeId) {
            req.error(400, "El campo viaje_ID es obligatorio.");
            return;
        }
        const viaje = await SELECT.one.from(Viajes).where({ ID: viajeId });
        if (!viaje) {
            req.error(404, `No existe un viaje con ID '${viajeId}'.`);
        }
    });

    srv.before("UPDATE", Telemetrias, async (req) => {
        const viajeId = req.data?.viaje_ID;
        if (viajeId) {
            const viaje = await SELECT.one.from(Viajes).where({ ID: viajeId });
            if (!viaje) {
                req.error(404, `No existe un viaje con ID '${viajeId}'.`);
            }
        }
    });

    // ── Recalcular métricas del viaje después de CREATE/UPDATE/DELETE ──
    srv.after("CREATE", Telemetrias, async (_, req) => {
        await recalcularViaje(req.data?.viaje_ID);
    });

    srv.after("UPDATE", Telemetrias, async (_, req) => {
        await recalcularViaje(req.data?.viaje_ID);
    });

    srv.after("DELETE", Telemetrias, async (_, req) => {
        // Para DELETE necesitamos obtener el viaje_ID antes de eliminar
        // CDS no lo incluye en req.data después del delete, así que
        // lo guardamos en un handler before DELETE
    });

    srv.before("DELETE", Telemetrias, async (req) => {
        const telemetria = await SELECT.one.from(Telemetrias).where({ ID: req.data.ID });
        req._viajeId = telemetria?.viaje_ID;
    });

    srv.after("DELETE", Telemetrias, async (_, req) => {
        await recalcularViaje(req._viajeId);
    });
};
