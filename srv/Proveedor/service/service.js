const cds = require("@sap/cds");
const { SELECT } = require("@sap/cds/lib/ql/cds-ql");

module.exports = async (srv) => {
    const { Proveedores, OrdenesCarga, SurtidosUnidad, Tanques } = cds.entities('ConfigService');
    srv.on("QuantityByAlmacen", async (req) => {
        const { AlmacenID } = req.data;
        const tx = cds.tx(req);

        const OrdenesCargaSum = await tx.run(
            SELECT.from(OrdenesCarga)
                .columns("SUM(carga_real) as totalSum", "proveedor.nombre")
                .where({ "almacen_ID": AlmacenID })
                .groupBy("proveedor.nombre")
        );

        const SurtidosUnidadSum = await tx.run(
            SELECT.from(SurtidosUnidad)
                .columns("SUM(carga_real) as totalSurtido", "proveedor.nombre")
                .where({"almacen_ID": AlmacenID })
                .groupBy("proveedor.nombre")
        );

        const result = GroupByProvider(OrdenesCargaSum, SurtidosUnidadSum);

        const QuantityPerTank = await SELECT.from(Tanques)
        .columns("nivel_actual", "descripcion")
        .where({almacen_ID: AlmacenID});
        
        return {
            PerAlmacen: result,
            PerTanques: QuantityPerTank
        };

            
    })
};

const GroupByProvider = (OrdenesCargaSum, SurtidosUnidadSum) => {
    const result = [];
    for (const orden of OrdenesCargaSum) {
        const proveedor = orden.proveedor_nombre;
        const totalSum = orden.totalSum;
        const totalSurtido = SurtidosUnidadSum.find(s => s.proveedor_nombre === proveedor)?.totalSurtido || 0;
        const capacidad = totalSum - totalSurtido;
        result.push({ proveedor, totalSum, totalSurtido, capacidad });
    }
    return result.sort((a, b) => b.capacidad - a.capacidad);
}