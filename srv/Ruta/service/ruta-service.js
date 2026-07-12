const cds = require("@sap/cds");
const { SELECT, UPDATE } = require("@sap/cds/lib/ql/cds-ql");

module.exports = async (srv) => {
    const { Rutas, PuntoCoordenadas } = cds.entities('ConfigService');

    /**
     * Helper: recalcula destinosCount para una ruta dada
     */
    async function recalcularDestinos(rutaId) {
        if (!rutaId) return;
        const countResult = await SELECT.one.from(PuntoCoordenadas)
            .where({ ruta_ID: rutaId })
            .columns('count(*) as count');
        const count = countResult?.count || 0;
        await UPDATE(Rutas).set({ destinosCount: count }).where({ ID: rutaId });
    }

    // ── Validación de coordenadas geográficas en PuntoCoordenada ──
    srv.before("CREATE", PuntoCoordenadas, async (req) => {
        const { latitud, longitud } = req.data;
        if (latitud !== undefined && latitud !== null) {
            const lat = parseFloat(latitud);
            if (isNaN(lat) || lat < -90 || lat > 90) {
                req.error(400, "La latitud debe estar entre -90 y 90.");
            }
        }
        if (longitud !== undefined && longitud !== null) {
            const lon = parseFloat(longitud);
            if (isNaN(lon) || lon < -180 || lon > 180) {
                req.error(400, "La longitud debe estar entre -180 y 180.");
            }
        }
    });

    srv.before("UPDATE", PuntoCoordenadas, async (req) => {
        const { latitud, longitud } = req.data;
        if (latitud !== undefined && latitud !== null) {
            const lat = parseFloat(latitud);
            if (isNaN(lat) || lat < -90 || lat > 90) {
                req.error(400, "La latitud debe estar entre -90 y 90.");
            }
        }
        if (longitud !== undefined && longitud !== null) {
            const lon = parseFloat(longitud);
            if (isNaN(lon) || lon < -180 || lon > 180) {
                req.error(400, "La longitud debe estar entre -180 y 180.");
            }
        }
    });

    // ── CREATE ──
    srv.after("CREATE", PuntoCoordenadas, async (_, req) => {
        const rutaId = req.data?.ruta_ID;
        if (rutaId) {
            await recalcularDestinos(rutaId);
        }
    });

    // ── UPDATE ──
    // Guardar ruta anterior antes de modificar
    srv.before("UPDATE", PuntoCoordenadas, async (req) => {
        const punto = await SELECT.one.from(PuntoCoordenadas).where({ ID: req.data.ID });
        req._rutaAnterior_ID = punto?.ruta_ID;
    });

    srv.after("UPDATE", PuntoCoordenadas, async (_, req) => {
        const rutaNueva = req.data?.ruta_ID;
        const rutaAnterior = req._rutaAnterior_ID;

        if (rutaNueva && rutaNueva !== rutaAnterior) {
            // Cambió de ruta: recalcular ambas
            await recalcularDestinos(rutaNueva);
            await recalcularDestinos(rutaAnterior);
        } else if (rutaNueva) {
            // Misma ruta: recalcular por si acaso
            await recalcularDestinos(rutaNueva);
        } else if (rutaAnterior) {
            // No vino ruta_ID en payload pero tenía una antes
            await recalcularDestinos(rutaAnterior);
        }
    });

    // ── DELETE ──
    // Guardar ruta antes de eliminar para poder recalcular después
    srv.before("DELETE", PuntoCoordenadas, async (req) => {
        const punto = await SELECT.one.from(PuntoCoordenadas).where({ ID: req.data.ID });
        req._rutaEliminar_ID = punto?.ruta_ID;
    });

    srv.after("DELETE", PuntoCoordenadas, async (_, req) => {
        const rutaId = req._rutaEliminar_ID;
        if (rutaId) {
            await recalcularDestinos(rutaId);
        }
    });
};
