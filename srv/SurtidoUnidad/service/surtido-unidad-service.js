const cds = require('@sap/cds');
const { UPDATE, SELECT } = require('@sap/cds/lib/ql/cds-ql');
const { SurtidosUnidad, OrdenesCarga, Tanques, Vehiculos, Almacenes } = cds.entities('ConfigService');

module.exports = async (srv) => {

    srv.before(['CREATE', 'UPDATE'], SurtidosUnidad, async (req) => {
        const allowIncomplete = req.data?.IsActiveEntity === false;
        await beforeUpsertSurtido(req, SurtidosUnidad, { allowIncomplete });
    });

    srv.before(['CREATE', 'UPDATE'], SurtidosUnidad.drafts, async (req) => {
        await beforeUpsertSurtido(req, SurtidosUnidad.drafts, { allowIncomplete: true });
    });


    srv.after('CREATE', SurtidosUnidad, async (data, req) => {
        if (req.data?.IsActiveEntity === false) return;

        const cargaReal = req.data.carga_real != null ? Number(req.data.carga_real) : null;
        const vehiculoId = req.data.vehiculo_ID;
        const tanqueId = req.data.tanque_ID;
        const isCargaExterna = req.data.cargaExterna === true || req.data.cargaExterna === 'true';

        if (cargaReal == null || !vehiculoId) return;

        const vehiculo = await SELECT.one.from(Vehiculos).where({ ID: vehiculoId });
        if (!vehiculo) {
            req.error(400, 'Vehículo no encontrado');
            return;
        }

        const volumenPrevioVehiculo = Number(vehiculo.nivelActualCombustible || 0);
        const volumenPosteriorVehiculo = volumenPrevioVehiculo + cargaReal;

        await UPDATE(Vehiculos)
            .set({ nivelActualCombustible: volumenPosteriorVehiculo })
            .where({ ID: vehiculoId });

        if (isCargaExterna) return;

        const tanque = await SELECT.one.from(Tanques).where({ ID: tanqueId });
        if (!tanque) {
            req.error(400, 'Tanque no encontrado');
            return;
        }

        const nuevoNivelTanque = Number(tanque.nivel_actual) - cargaReal;
        await UPDATE(Tanques)
            .set({ nivel_actual: nuevoNivelTanque })
            .where({ ID: tanqueId });

        if (tanque.nivel_minimo != null && nuevoNivelTanque <= Number(tanque.nivel_minimo)) {
            req.warn(`Alerta: el tanque alcanzó el nivel mínimo (${tanque.nivel_minimo}). Nivel actual: ${nuevoNivelTanque}`);
        }

        const ordenCargaId = req.data.ordenCarga_ID;
        if (!ordenCargaId) return;

        let activeOrdenCarga = await SELECT.one.from(OrdenesCarga).where({ isFirst: true });
        let ordenesEntity = OrdenesCarga;
        if (!activeOrdenCarga && OrdenesCarga.drafts) {
            activeOrdenCarga = await SELECT.one.from(OrdenesCarga.drafts).where({ isFirst: true });
            if (activeOrdenCarga) ordenesEntity = OrdenesCarga.drafts;
        }

        if (!activeOrdenCarga || activeOrdenCarga.ID !== ordenCargaId) return;

        const recordsSurtido = await SELECT.from(SurtidosUnidad).where({ ordenCarga_ID: activeOrdenCarga.ID });
        const sumSurtido = recordsSurtido.reduce((acc, record) => acc + Number(record.carga_real || 0), 0);

        if (sumSurtido < Number(activeOrdenCarga.carga_real)) return;

        await UPDATE(ordenesEntity).set({ isFirst: false }).where({ ID: activeOrdenCarga.ID });

        const nextOrdenCarga = await SELECT.one.from(ordenesEntity).where({
            fechaCarga: { '>=': activeOrdenCarga.fechaCarga },
            isFirst: { '!=': true },
            ID: { '!=': activeOrdenCarga.ID }
        }).orderBy('fechaCarga').limit(1);

        if (nextOrdenCarga) {
            await UPDATE(ordenesEntity).set({ isFirst: true }).where({ ID: nextOrdenCarga.ID });
        }
    });

};

const beforeUpsertSurtido = async (req, surtidosEntity, options = {}) => {
    const { allowIncomplete = false } = options;

    let currentSurtido = null;
    if (req.event === 'UPDATE' && req.data?.ID) {
        currentSurtido = await SELECT.one.from(surtidosEntity).where({ ID: req.data.ID });
    }

    const tanqueId = req.data.tanque_ID ?? currentSurtido?.tanque_ID;
    const vehiculoId = req.data.vehiculo_ID ?? currentSurtido?.vehiculo_ID;
    const almacenIdInput = req.data.almacen_ID ?? currentSurtido?.almacen_ID;
    const cargaRealRaw = req.data.carga_real ?? currentSurtido?.carga_real;
    const cargaReal = cargaRealRaw != null ? Number(cargaRealRaw) : null;

    const isCargaExterna = req.data.cargaExterna === true || req.data.cargaExterna === 'true' || currentSurtido?.cargaExterna === true;
    const nombreEstacionServicio = req.data.nombreEstacionServicio ?? currentSurtido?.nombreEstacionServicio;
    const precioCombustible = req.data.precioCombustible ?? currentSurtido?.precioCombustible;

    if (cargaReal != null && cargaReal <= 0) {
        req.error(400, 'La carga solicitada debe ser mayor a 0');
        return;
    }

    if (!allowIncomplete && req.event === 'CREATE' && cargaReal == null) {
        req.error(400, 'Debe indicar la carga solicitada');
        return;
    }

    if (isCargaExterna) {
        if (!allowIncomplete && (!nombreEstacionServicio || !String(nombreEstacionServicio).trim())) {
            req.error(400, 'Debe indicar la estación de servicio cuando la carga es externa');
            return;
        }
        if (!allowIncomplete && (precioCombustible == null || Number(precioCombustible) <= 0)) {
            req.error(400, 'Debe indicar un precio de combustible válido cuando la carga es externa');
            return;
        }
    } else if (!allowIncomplete && !tanqueId) {
        req.error(400, 'Debe indicar el tanque para realizar el surtido');
        return;
    }

    let activeOrdenCarga = null;
    if (!isCargaExterna) {
        activeOrdenCarga = await SELECT.one.from(OrdenesCarga).where({ isFirst: true });
        if (!activeOrdenCarga && OrdenesCarga.drafts) {
            activeOrdenCarga = await SELECT.one.from(OrdenesCarga.drafts).where({ isFirst: true });
        }
    }

    let tanque = null;
    if (!isCargaExterna && tanqueId) {
        tanque = await SELECT.one.from(Tanques).where({ ID: tanqueId });
        if (!tanque && Tanques.drafts) {
            tanque = await SELECT.one.from(Tanques.drafts).where({ ID: tanqueId });
        }

        if (!tanque) {
            req.error(400, 'Tanque no encontrado');
            return;
        }

        if (tanque.estadoTanque_code && tanque.estadoTanque_code !== 'Operativo') {
            req.error(400, `El tanque seleccionado no esta operativo (estado: ${tanque.estadoTanque_code})`);
            return;
        }

        const almacenIdEfectivo = almacenIdInput || activeOrdenCarga?.almacen_ID;

        if (almacenIdEfectivo && tanque.almacen_ID && almacenIdEfectivo !== tanque.almacen_ID) {
            req.error(400, 'El tanque seleccionado no pertenece al almacén indicado');
            return;
        }

        if (cargaReal != null && cargaReal > Number(tanque.nivel_actual || 0)) {
            req.error(400, 'La carga excede el nivel actual del tanque');
            return;
        }
    }

    let vehiculo = null;
    if (vehiculoId) {
        vehiculo = await SELECT.one.from(Vehiculos).where({ ID: vehiculoId });
        if (!vehiculo && Vehiculos.drafts) {
            vehiculo = await SELECT.one.from(Vehiculos.drafts).where({ ID: vehiculoId });
        }

        if (!vehiculo) {
            req.error(400, 'Vehículo no encontrado');
            return;
        }

        const volumenPrevioVehiculo = Number(vehiculo.nivelActualCombustible || 0);
        const capacidadVehiculo = Number(vehiculo.capacidadTotal || 0);
        const volumenPosteriorVehiculo = cargaReal != null ? volumenPrevioVehiculo + cargaReal : volumenPrevioVehiculo;
        req.data.volumenPrevioVehiculo = volumenPrevioVehiculo;
        req.data.volumen_actual_vehiculo = volumenPosteriorVehiculo;

        if (cargaReal != null && capacidadVehiculo > 0 && volumenPosteriorVehiculo > capacidadVehiculo) {
            req.error(400, 'La suma del nivel actual del vehículo y la carga solicitada excede la capacidad del vehículo');
            return;
        }

        const almacenId = almacenIdInput || activeOrdenCarga?.almacen_ID || tanque?.almacen_ID;
        if (almacenId) {
            let almacen = await SELECT.one.from(Almacenes).where({ ID: almacenId });
            if (!almacen && Almacenes.drafts) {
                almacen = await SELECT.one.from(Almacenes.drafts).where({ ID: almacenId });
            }

            if (almacen && vehiculo.tipo_combustible && almacen.tipo_combustible && vehiculo.tipo_combustible !== almacen.tipo_combustible) {
                req.error(400, 'El tipo de combustible del vehículo no coincide con el del almacén');
                return;
            }
        }

        if (!isCargaExterna && tanque && vehiculo.tipo_combustible && tanque.tipo_combustible && vehiculo.tipo_combustible !== tanque.tipo_combustible) {
            req.error(400, 'El tipo de combustible del vehículo no coincide con el del tanque');
            return;
        }
    }

    if (!isCargaExterna) {
        const almacenIdForStock = almacenIdInput || activeOrdenCarga?.almacen_ID || tanque?.almacen_ID;
        if (almacenIdForStock) {
            const tanquesAlmacen = await SELECT.from(Tanques)
                .columns('nivel_actual')
                .where({ almacen_ID: almacenIdForStock });

            const inventarioTotalAlmacen = tanquesAlmacen.reduce(
                (acc, record) => acc + Number(record.nivel_actual || 0),
                0
            );

            if (cargaReal != null && cargaReal > inventarioTotalAlmacen) {
                req.error(400, `La carga solicitada excede el inventario total disponible del almacén (${inventarioTotalAlmacen})`);
                return;
            }
        }
    }

    if (!isCargaExterna && activeOrdenCarga) {
        req.data.proveedor_ID = activeOrdenCarga.proveedor_ID;
        req.data.almacen_ID = almacenIdInput || activeOrdenCarga.almacen_ID;
        req.data.ordenCarga_ID = activeOrdenCarga.ID;
    } else if (isCargaExterna) {
        req.data.ordenCarga_ID = null;
    }
};