const cds = require("@sap/cds");
const handlers = [
    require("./OrdenCarga/service/orden-carga-service"),
    require("./SurtidoUnidad/service/surtido-unidad-service"),
    require("./Proveedor/service/service"),
    require("./Viaje/service/viaje-service"),
    require("./Chofer/service/chofer-service"),
    require("./Tanques/service/tanques-service")
    // Almacén opera por CDS nativo, no requiere handler custom
]

class ConfigService extends cds.ApplicationService {
    async init() {
        for await (const handler of handlers) {
            handler(this);
        }

        return super.init();
    }
}   

module.exports = { ConfigService };