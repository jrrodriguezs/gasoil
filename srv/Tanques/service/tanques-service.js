const cds = require("@sap/cds");
const { SELECT, UPDATE } = require("@sap/cds/lib/ql/cds-ql");
const { Tanques, SurtidosUnidad, TankXOrden, OrdenesCarga, Almacenes } = cds.entities('ConfigService');

module.exports = async (srv) => {

    srv.before('CREATE', Tanques, async (req) => {
        const almacenId = req.data?.almacen_ID;
        if (!almacenId) return;

        if (!req.data?.codigo) {
            const nextSequence = await getNextTanqueSequence(almacenId);
            req.data.codigo = `tanque_${nextSequence}`;
            if (!req.data?.descripcion) {
                req.data.descripcion = `Tanque ${nextSequence}`;
            }
        }

        if (!req.data?.estadoTanque_code) {
            req.data.estadoTanque_code = 'Operativo';
        }

        await validateTanqueData(req, Tanques);
    });
    
    srv.before('UPDATE', Tanques, async (req) => {
        const almacenId = req.data?.almacen_ID;

        if (req.data?.ID) {
            const existingTanque = await SELECT.one.from(Tanques).where({ ID: req.data.ID });
            req._oldAlmacenId = existingTanque?.almacen_ID;
        }

        await validateTanqueData(req, Tanques);
    });

    srv.after(['CREATE', 'UPDATE'], Tanques, async (data, req) => {
        if (data?.nivel_actual == null || data?.nivel_minimo == null) return;
        const nivelActual = Number(data.nivel_actual);
        const nivelMinimo = Number(data.nivel_minimo);

        if (Number.isNaN(nivelActual) || Number.isNaN(nivelMinimo)) return;
        if (nivelMinimo > 0 && nivelActual <= nivelMinimo) {
            req.warn(`Alerta: el tanque está en o por debajo del nivel mínimo (${nivelMinimo}). Nivel actual: ${nivelActual}`);
        }

        let currentAlmacenId = data?.almacen_ID || req.data?.almacen_ID;
        if (!currentAlmacenId) {
            const entityId = data?.ID || req.data?.ID;
            if (entityId) {
                const tanque = await SELECT.one.from(Tanques).columns('almacen_ID').where({ ID: entityId });
                currentAlmacenId = tanque?.almacen_ID;
            }
        }
    });

    srv.before(['CREATE', 'UPDATE'], Tanques.drafts, async (req) => {
        const almacenId = req.data?.almacen_ID;

        if (req.event === 'CREATE' && !req.data?.codigo) {
            const nextSequence = await getNextTanqueSequence(almacenId);
            req.data.codigo = `tanque_${nextSequence}`;
            if (!req.data?.descripcion) {
                req.data.descripcion = `Tanque ${nextSequence}`;
            }
        }

        if (req.event === 'CREATE' && !req.data?.estadoTanque_code) {
            req.data.estadoTanque_code = 'Operativo';
        }

        await validateTanqueData(req, Tanques.drafts, { allowIncomplete: true });
    });

    srv.before('DELETE', Tanques, async (req) => {
        const tanqueId = req.data?.ID;
        if (!tanqueId) return;

        const existingTanque = await SELECT.one.from(Tanques).where({ ID: tanqueId });
        req._oldAlmacenId = existingTanque?.almacen_ID;

        const surtidoRelacionado = SurtidosUnidad
            ? await SELECT.one.from(SurtidosUnidad).where({ tanque_ID: tanqueId })
            : null;

        if (surtidoRelacionado) {
            req.error(400, 'No se puede eliminar el tanque porque tiene surtidos por unidad asociados');
            return;
        }

        const detalleOrdenRelacionado = TankXOrden
            ? await SELECT.one.from(TankXOrden).where({ tanque_ID: tanqueId })
            : null;

        if (detalleOrdenRelacionado) {
            req.error(400, 'No se puede eliminar el tanque porque está asociado a órdenes de carga (subtabla)');
            return;
        }

        const ordenDirectaRelacionada = OrdenesCarga
            ? await SELECT.one.from(OrdenesCarga).where({ tanque_ID: tanqueId })
            : null;

        if (ordenDirectaRelacionada) {
            req.error(400, 'No se puede eliminar el tanque porque está referenciado en una orden de carga');
            return;
        }
    });
};

const getNextTanqueSequence = async (almacenId) => {
    let activeQuery = SELECT.from(Tanques).columns('codigo');
    let draftQuery = Tanques.drafts
        ? SELECT.from(Tanques.drafts).columns('codigo')
        : null;

    if (almacenId) {
        activeQuery = activeQuery.where({ almacen_ID: almacenId });
        if (draftQuery) {
            draftQuery = draftQuery.where({ almacen_ID: almacenId });
        }
    }

    const activeRows = await activeQuery;
    const draftRows = draftQuery ? await draftQuery : [];

    const maxCorrelativo = [...activeRows, ...draftRows].reduce((max, row) => {
        const codigo = String(row?.codigo || '').trim();
        const match = /^tanque_(\d+)$/i.exec(codigo);
        if (!match) return max;
        const value = Number(match[1]);
        return Number.isNaN(value) ? max : Math.max(max, value);
    }, 0);

    return maxCorrelativo + 1;
};

const validateTanqueData = async (req, entity, options = {}) => {
    const { allowIncomplete = false } = options;
    let existingTanque = null;
    if (req.data?.ID) {
        existingTanque = await SELECT.one.from(entity).where({ ID: req.data.ID });
    }

    const capacidadTotal = req.data.capacidadTotal != null
        ? Number(req.data.capacidadTotal)
        : existingTanque?.capacidadTotal != null
            ? Number(existingTanque.capacidadTotal)
            : null;

    const nivelActual = req.data.nivel_actual != null
        ? Number(req.data.nivel_actual)
        : existingTanque?.nivel_actual != null
            ? Number(existingTanque.nivel_actual)
            : null;

    const nivelMinimo = req.data.nivel_minimo != null
        ? Number(req.data.nivel_minimo)
        : existingTanque?.nivel_minimo != null
            ? Number(existingTanque.nivel_minimo)
            : null;

    if (allowIncomplete && capacidadTotal == null) {
        return;
    }

    if (capacidadTotal == null || capacidadTotal <= 0) {
        req.error(400, 'La capacidad total debe ser mayor a 0');
        return;
    }

    if (nivelActual != null && nivelActual < 0) {
        req.error(400, 'El nivel actual no puede ser negativo');
        return;
    }

    if (nivelMinimo != null && nivelMinimo < 0) {
        req.error(400, 'El nivel mínimo no puede ser negativo');
        return;
    }

    if (nivelActual != null && nivelActual > capacidadTotal) {
        req.error(400, 'El nivel actual no puede superar la capacidad total del tanque');
        return;
    }

    if (nivelMinimo != null && nivelMinimo > capacidadTotal) {
        req.error(400, 'El nivel mínimo no puede superar la capacidad total del tanque');
        return;
    }
};
