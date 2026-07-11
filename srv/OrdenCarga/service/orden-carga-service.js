const cds = require("@sap/cds");
const { UPDATE, SELECT } = require("@sap/cds/lib/ql/cds-ql");

module.exports = async (srv) => {
    const { OrdenesCarga, Tanques, PreciosHistoricos } = cds.entities('ConfigService');

    srv.before(["CREATE", 'UPDATE'], OrdenesCarga, async (req) => {
        const { to_tanques, carga_real } = req.data;
        const hasTanquesDetalle = Array.isArray(to_tanques) && to_tanques.length > 0;
        const totalTotanques = hasTanquesDetalle
            ? to_tanques.reduce((total, tanque) => total + Number(tanque.quantity || 0), 0)
            : 0;

        const ordenesActivas = await SELECT.from(OrdenesCarga).where({ isFirst: true });
        if (hasTanquesDetalle && carga_real != null && Number(carga_real) !== totalTotanques) {
            req.error(400, `La carga real (${carga_real}) no coincide con la suma de las cantidades de los tanques (${totalTotanques})`);
        }

        if (req.event === 'CREATE' && ordenesActivas.length == 0) {
            req.data.isFirst = true;
        }

        if (!hasTanquesDetalle) {
            return;
        }

        let totalSolicitado = 0;
        let totalDisponible = 0;

        for await (const tanque of to_tanques) {
            const { tanque_ID } = tanque;
            const cantidad = Number(tanque.quantity || 0);
            const tanqueExistente = await SELECT.one.from(Tanques).where({ ID: tanque_ID });

            if (!tanqueExistente) {
                req.error(400, `Tanque con ID ${tanque_ID} no existe`);
                continue;
            }

            if (tanqueExistente.estadoTanque_code && tanqueExistente.estadoTanque_code !== 'Operativo') {
                req.error(400, `No se puede asignar carga al tanque ${tanque_ID} porque no esta operativo (estado: ${tanqueExistente.estadoTanque_code})`);
                continue;
            }

            const disponibleTanque = Number(tanqueExistente.capacidadTotal || 0) - Number(tanqueExistente.nivel_actual || 0);

            if (cantidad <= 0) {
                req.error(400, `La cantidad para el tanque ${tanque_ID} debe ser mayor a 0`);
                continue;
            }

            if (cantidad > disponibleTanque) {
                req.error(400, `La carga para el tanque ${tanque_ID} excede su capacidad disponible (${disponibleTanque})`);
                continue;
            }
            await UPDATE(Tanques).set({ nivel_actual: Number(tanqueExistente.nivel_actual || 0) + cantidad }).where({ ID: tanque_ID });

        }

        if (req.errors && req.errors.length) {
            return;
        }
    });

    srv.before("UPDATE", OrdenesCarga.drafts, async (req) => {
        const record = await SELECT.one.from(OrdenesCarga.drafts).where({ ID: req.data.ID });
        if (!record) {
            req.error(404, "Registro no encontrado");
            return;
        }
        // intercambiar keys que esten en req.data con las del record para que se puedan usar en el calculo, 
        // si no estan en req.data se usan las del record
        const updatedRecord = Object.assign({}, record, req.data);
        const proveedorId = updatedRecord.proveedor_ID;
        const cargaReal = updatedRecord.carga_real;
        const cargaFacturada = updatedRecord.carga_facturada;

        if (cargaReal != null && proveedorId) {
            const proveedorExistente = await SELECT.one.from(PreciosHistoricos)
                .orderBy("fecha desc")
                .where({ proveedor_ID: proveedorId });

            if (proveedorExistente) {
                req.data.precio = cargaReal * Number(proveedorExistente.precio || 0);
            }
        }

        if (cargaReal != null && cargaFacturada != null) {
            const variacion = cargaFacturada - cargaReal;
            const porcentajeConciliacion = cargaFacturada === 0
                ? 0
                : Number(((variacion / cargaFacturada) * 100).toFixed(2));

            req.data.variacion = variacion;
            req.data.porcentaje_conciliacion = porcentajeConciliacion;
        }
    });
}