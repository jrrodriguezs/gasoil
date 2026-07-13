const cds = require("@sap/cds");
const { SELECT } = require("@sap/cds/lib/ql/cds-ql");

module.exports = async (srv) => {
    const { Proveedores, OrdenesCarga, SurtidosUnidad, Tanques } = cds.entities('ConfigService');
    srv.on("QuantityByAlmacen", async (req) => {
        const { AlmacenID } = req.data;
        const tx = cds.tx(req);

        const [OrdenesCargaSum, SurtidosUnidadSum] = await Promise.all([
            tx.run(
                SELECT.from(OrdenesCarga)
                    .columns("SUM(carga_real) as totalSum", "proveedor.nombre")
                    .where({ "almacen_ID": AlmacenID })
                    .groupBy("proveedor.nombre")
            ),
            tx.run(
                SELECT.from(SurtidosUnidad)
                    .columns("SUM(carga_real) as totalSurtido", "proveedor.nombre")
                    .where({ "almacen_ID": AlmacenID })
                    .groupBy("proveedor.nombre")
            )
        ]);

        const result = GroupByProvider(OrdenesCargaSum, SurtidosUnidadSum);

        const QuantityPerTank = await tx.run(
            SELECT.from(Tanques)
                .columns("nivel_actual", "descripcion", "capacidadTotal", "nivel_minimo")
                .where({ almacen_ID: AlmacenID })
        );

        const QuantityPerTankWithColor = QuantityPerTank.map(t => ({
            ...t,
            color: Number(t.nivel_actual) <= Number(t.nivel_minimo) ? 'Error' :
                   (Number(t.nivel_actual) <= Number(t.nivel_minimo) * 1.5 ? 'Critical' : 'Good')
        }));
        
        return {
            PerAlmacen: result,
            PerTanques: QuantityPerTankWithColor
        };
    });

    srv.on("AlmacenVolumeHistory", async (req) => {
        const { AlmacenID } = req.data;
        const tx = cds.tx(req);

        const [latestOrder, latestSurtido] = await Promise.all([
            tx.run(
                SELECT.from(OrdenesCarga)
                    .columns("fechaCarga")
                    .where({ "almacen_ID": AlmacenID })
                    .orderBy({ fechaCarga: 'desc' })
                    .limit(1)
            ),
            tx.run(
                SELECT.from(SurtidosUnidad)
                    .columns("fechaCarga")
                    .where({ "almacen_ID": AlmacenID })
                    .orderBy({ fechaCarga: 'desc' })
                    .limit(1)
            )
        ]);

        const orderDate = latestOrder?.[0]?.fechaCarga ? new Date(latestOrder[0].fechaCarga) : null;
        const surtidoDate = latestSurtido?.[0]?.fechaCarga ? new Date(latestSurtido[0].fechaCarga) : null;

        let end;
        if (orderDate || surtidoDate) {
            end = new Date(Math.max(orderDate ? orderDate.getTime() : 0, surtidoDate ? surtidoDate.getTime() : 0));
        } else {
            end = new Date();
        }
        end.setHours(23, 59, 59, 999);
        const start = new Date(end);
        start.setDate(start.getDate() - 30);
        start.setHours(0, 0, 0, 0);

        const [orders, surtidos] = await Promise.all([
            tx.run(
                SELECT.from(OrdenesCarga)
                    .columns("fechaCarga", "carga_real")
                    .where({
                        "almacen_ID": AlmacenID,
                        "fechaCarga": { between: start.toISOString(), and: end.toISOString() }
                    })
            ),
            tx.run(
                SELECT.from(SurtidosUnidad)
                    .columns("fechaCarga", "carga_real")
                    .where({
                        "almacen_ID": AlmacenID,
                        "fechaCarga": { between: start.toISOString(), and: end.toISOString() }
                    })
            )
        ]);

        const cargaPorDia = {};
        for (const o of orders) {
            const fecha = new Date(o.fechaCarga).toISOString().split('T')[0];
            cargaPorDia[fecha] = (cargaPorDia[fecha] || 0) + Number(o.carga_real || 0);
        }

        const surtidoPorDia = {};
        for (const s of surtidos) {
            const fecha = new Date(s.fechaCarga).toISOString().split('T')[0];
            surtidoPorDia[fecha] = (surtidoPorDia[fecha] || 0) + Number(s.carga_real || 0);
        }

        const capacidadActualResult = await tx.run(
            SELECT.from(Tanques)
                .columns("SUM(nivel_actual) as total")
                .where({ almacen_ID: AlmacenID })
        );
        const capacidadActual = Number(capacidadActualResult?.[0]?.total || 0);

        const result = [];
        const current = new Date(start);
        let capacidadDia = capacidadActual;
        const days = [];
        while (current <= end) {
            const fecha = current.toISOString().split('T')[0];
            days.push({ fecha, capacidad: 0 });
            current.setDate(current.getDate() + 1);
        }

        for (let i = days.length - 1; i >= 0; i--) {
            const fecha = days[i].fecha;
            const carga = cargaPorDia[fecha] || 0;
            const surtido = surtidoPorDia[fecha] || 0;
            if (i === days.length - 1) {
                capacidadDia = capacidadActual;
            } else {
                capacidadDia = capacidadDia - carga + surtido;
            }
            days[i].capacidad = capacidadDia;
        }

        return { items: days };
    });
};

const GroupByProvider = (OrdenesCargaSum, SurtidosUnidadSum) => {
    const surtidosMap = new Map(
        SurtidosUnidadSum.map(s => [s.proveedor_nombre, s.totalSurtido])
    );
    const result = OrdenesCargaSum.map(orden => {
        const proveedor = orden.proveedor_nombre;
        const totalSum = orden.totalSum;
        const totalSurtido = surtidosMap.get(proveedor) || 0;
        const capacidad = totalSum - totalSurtido;
        return { proveedor, totalSum, totalSurtido, capacidad };
    });
    return result.sort((a, b) => b.capacidad - a.capacidad);
};
