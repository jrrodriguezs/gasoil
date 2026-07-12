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
                .columns("nivel_actual", "descripcion")
                .where({ almacen_ID: AlmacenID })
        );
        
        return {
            PerAlmacen: result,
            PerTanques: QuantityPerTank
        };
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
