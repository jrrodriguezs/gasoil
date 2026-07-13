const cds = require("@sap/cds");
const handlers = [
    require("./OrdenCarga/service/orden-carga-service"),
    require("./SurtidoUnidad/service/surtido-unidad-service"),
    require("./Proveedor/service/service"),
    require("./Viaje/service/viaje-service"),
    require("./Chofer/service/chofer-service"),
    require("./Tanques/service/tanques-service"),
    require("./Vehiculo/service/vehiculo-service"),
    require("./Ruta/service/ruta-service"),
    require("./Telemetria/service/telemetria-service"),
    require("./Maps/maps-service")
    // Almacén opera por CDS nativo, no requiere handler custom
]

class ConfigService extends cds.ApplicationService {
    async init() {
        await super.init();
        for await (const handler of handlers) {
            handler(this);
        }
        return this;
    }
}

module.exports = { ConfigService };
