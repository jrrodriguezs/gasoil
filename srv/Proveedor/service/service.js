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

        // Calcular capacidad máxima del almacén (suma de capacidadTotal de tanques) y capacidad actual
        const [capacidadTotalResult, capacidadActualResult] = await Promise.all([
            tx.run(
                SELECT.from(Tanques)
                    .columns("SUM(capacidadTotal) as total")
                    .where({ almacen_ID: AlmacenID })
            ),
            tx.run(
                SELECT.from(Tanques)
                    .columns("SUM(nivel_actual) as total")
                    .where({ almacen_ID: AlmacenID })
            )
        ]);

        const capacidadTotalAlmacen = Number(capacidadTotalResult?.[0]?.total || 0);
        const capacidadActual = Number(capacidadActualResult?.[0]?.total || 0);

        // Rango de fechas: hoy - 30 días hasta hoy
        const end = new Date();
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

        // Generar los 31 días y calcular capacidad histórica desde el más reciente hacia atrás
        const days = [];
        const current = new Date(start);
        while (current <= end) {
            const fecha = current.toISOString().split('T')[0];
            days.push({ fecha, capacidad: 0 });
            current.setDate(current.getDate() + 1);
        }

        let capacidadDia = capacidadActual;
        for (let i = days.length - 1; i >= 0; i--) {
            if (i === days.length - 1) {
                capacidadDia = capacidadActual;
            } else {
                const fechaSiguiente = days[i + 1].fecha;
                const carga = cargaPorDia[fechaSiguiente] || 0;
                const surtido = surtidoPorDia[fechaSiguiente] || 0;
                capacidadDia = capacidadDia - carga + surtido;
            }
            days[i].capacidad = Math.max(0, capacidadDia);
        }

        return { items: days, capacidadTotalAlmacen: capacidadTotalAlmacen };
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
