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
        capacidadTotal: Double;
        nivel_minimo: Double;
        nivel_actual: Double;
    }
    
    type QuantityByAlmacenResult{
        PerAlmacen: many AlmacenResult;
        PerTanques: many TanqueResult;
    }

    type VolumeHistoryItem {
        fecha: Date;
        capacidad: Double;
    }

    type VolumeHistoryResult {
        items: many VolumeHistoryItem;
        capacidadTotalAlmacen: Double;
    }

    function QuantityByAlmacen (AlmacenID: UUID) returns QuantityByAlmacenResult;
    function AlmacenVolumeHistory (AlmacenID: UUID) returns VolumeHistoryResult;
}
