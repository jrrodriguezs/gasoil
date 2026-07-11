using {gas.app.Proveedor} from '../../../db/Proveedor/proveedor-schema';
using {
    gas.app.Proveedor       as DbProveedor,
    gas.app.PrecioHistorico as DbPrecioHistorico
} from '../../../db/schema';
using from '../../config-service';

extend service ConfigService with {
    @cds.redirection.target: true
    @odata.draft.enabled
    entity Proveedores        as
        projection on DbProveedor {
            *,
            precios
        };

    entity PreciosHistoricos  as projection on DbPrecioHistorico;
	type AlmacenResult {
		proveedor: String;
		totalSum: Double;
		totalSurtido: Double;
		capacidad: Double;
	}
    type TanqueResult {
        descripcion: String;
        nivel_actual: Double;
    }
    
    type QuantityByAlmacenResult{
        PerAlmacen: many AlmacenResult;
        PerTanques: many TanqueResult;
    }

    function QuantityByAlmacen (AlmacenID: UUID) returns QuantityByAlmacenResult;
}
