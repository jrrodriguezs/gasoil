using from '../../config-service';
using { ConfigService.Vehiculos as Vehiculos} from '../../Vehiculo/service/vehiculo-service';
using { ConfigService.Tanques as Tanques} from '../../Tanques/service/tanques-service';
using {ConfigService.Viajes as Viajes} from '../../Viaje/service/viaje-service';
using {
    ConfigService.Proveedores as Proveedores, 
    ConfigService.PreciosHistoricos as PreciosHistoricos
} from '../../Proveedor/service/service';

extend service ConfigService with {

    @odata.draft.enabled: false
    define view PerformacePerVehicle as select from Vehiculos {
        key ID,
        placa,
        modelo,
        promedioKm,
    }where promedioKm is not null;
    
    @odata.draft.enabled: false
    define view PerformanceAvg as select from Viajes {
        key avg(kilometrosPorLitro) as rendimientoPromedioGeneral: Decimal(10,2),
        count(ID)                   as totalViajes : Integer,
    };

    @odata.draft.enabled: false
    define view PerformanceByModel as select from Vehiculos {
        key modelo,
        avg(promedioKm) as rendimientoPromedio: Decimal(10,2),
    }where promedioKm is not null group by modelo;

    define view TankCapacity as select from Tanques {
        key ID,
        estadoTanque.code as estado,
        codigo,
        (descripcion || ' - ' || almacen.nombreSede) as descripcion:String,
        (nivel_actual || ' / ' || capacidadTotal || ' L') as nivelActual: String,
        nivel_minimo,
        (capacidadTotal - nivel_actual) as capacidadDisponible: Decimal(10, 2),
        //porcentaje llenado
        case
            when capacidadTotal = 0
                then 0
            else round((nivel_actual * 100.0) / capacidadTotal, 2)
            end as porcentajeLlenado : Decimal(5, 2),
        case 
            when $self.porcentajeLlenado <= 25 then 1
            when $self.porcentajeLlenado > 25 and $self.porcentajeLlenado <= 50 then 2
            else 3
            end as criticality : Integer
    } where estadoTanque.code = 'Operativo';
    
    @odata.draft.enabled: false
    define view PerformancePerRoute as select from Viajes {
        avg(kilometrosPorLitro) as rendimientoPromedio: Decimal(10,2),
        key ruta.descripcion as ruta:String
    }group by ruta.descripcion;

    @odata.draft.enabled: false
    define view PerformancePerWeight as select from Viajes {
        avg(kilometrosPorLitro) as rendimientoPromedio: Decimal(10,2),
        key case 
            when pesoCarga >= 0 and pesoCarga <= 10000 then '0-10000 kg'
            when pesoCarga >= 10000 and pesoCarga <= 20000 then '10000-20000 kg'
            when pesoCarga >= 20000 and pesoCarga <= 30000 then '20000-30000 kg'
            else '30000+ kg'
            end as rangoPeso:String
    }group by $self.rangoPeso order by rendimientoPromedio desc;

    @odata.draft.enabled: false
    define view VehiclePerStatus as select from Vehiculos {
        key estadodelvehiculo.code as estado,
        count(ID) as cantidad: Integer
    } group by estadodelvehiculo.code order by cantidad desc;

    @odata.draft.enabled: false
    define view TankPerStatus as select from Tanques {
        @title : 'Estado del Tanque'
        key estadoTanque.code as status,
        count(ID) as cantidad: Integer
    }group by estadoTanque.code order by cantidad desc;

    @odata.draft.enabled: false
    define view CostoCombustiblePromedio as select from Viajes {
        key 'ABC' as id:String,
        sum(consumoRealTotal) as totalCombustibleConsumido: Decimal(12,2),
        sum(kilometrosRecorridos) as totalKilometrosRecorridos: Decimal(12,2),
        (select avg(ultimoPrecio) from UltimoPrecioCombustibleProveedor) as precioPromedioCombustible: Decimal(10,2),
        $self.totalCombustibleConsumido * $self.precioPromedioCombustible as costoCombustible: Decimal(12,2),
        $self.costoCombustible / $self.totalCombustibleConsumido as costoPromedioPorLitro: Decimal(10,2),
        case
            when $self.totalKilometrosRecorridos = 0 or $self.totalKilometrosRecorridos is null then 0
            else round($self.costoCombustible / $self.totalKilometrosRecorridos, 2)
        end as costoPorKm: Decimal(10,2)
    }

    @odata.draft.enabled: false
    define view UltimoPrecioCombustibleProveedor as select from Proveedores {
        key ID,
        nombre,
        (select precioCombustible from PreciosHistoricos as ph where ph.proveedor.ID = Proveedores.ID order by ph.fecha desc limit 1) as ultimoPrecio: Decimal(10,2)
    }

    @odata.draft.enabled: false
    define view TankCritical as select from Tanques{
        key count(ID) as cantidad: Integer
    } where Tanques.estadoTanque.code = 'Operativo'
      and round((Tanques.nivel_actual * 100.0) / Tanques.capacidadTotal, 2) <= 25;

    @odata.draft.enabled: false
    define view PerformancePlannedVSReal as select from Viajes {
        key 'ABC' as id:String,
        avg(kilometrosPorLitro) as rendimientoPromedioReal: Decimal(10,2),
        avg(vehiculo.rendimientoBase) as rendimientoPromedioTeorico: Decimal(10,2),
        case 
            when $self.rendimientoPromedioTeorico = 0  or $self.rendimientoPromedioTeorico is null then 0
            else round((($self.rendimientoPromedioReal - $self.rendimientoPromedioTeorico) / $self.rendimientoPromedioTeorico) * 100, 2)
        end as variacionPorcentual: Decimal(10,2)
    }

    @odata.draft.enabled: false
    define view DriverPerformance as select from Viajes {
        key chofer.ID as chofer_ID: UUID,
            avg(kilometrosPorLitro) as rendimientoPromedio: Decimal(10,2)
    } group by chofer.ID;

    @odata.draft.enabled: false
    define view DriverRating as select from DriverPerformance {
        key 'ABC' as id:String,
            avg(rendimientoPromedio) as rendimientoPromedioConductores: Decimal(10,2),
            case
                when avg(rendimientoPromedio) is null then 0
                when avg(rendimientoPromedio) * 25 > 100 then 100
                else round(avg(rendimientoPromedio) * 25, 2)
            end as calificacionPromedioConductores: Decimal(5,2)
    };

    @odata.draft.enabled: false
    define view PerformacePerMotor as select from Vehiculos{
        key case 
            when motor.modelo is null then 'No especificado'
            else motor.modelo.name
        end as modeloMotor : String,
        avg(promedioKm) as rendimiento: Decimal(10,2),
        max(promedioKm) as rendimientoMaximo: Decimal(10,2),
    }group by $self.modeloMotor;

    @odata.draft.enabled: false
    define view PerformacePerTransmision as select from Vehiculos{
        key case 
            when transmision.modeloDiferencial is null then 'No especificado'
            else transmision.modeloDiferencial
        end as modeloDiferencial : String,
        avg(promedioKm) as rendimiento: Decimal(10,2),
        max(promedioKm) as rendimientoMaximo: Decimal(10,2),
    }group by  $self.modeloDiferencial;

    @odata.draft.enabled: false
    define view PerformacePerCaja as select from Vehiculos{
        key case 
            when caja.modeloCaja is null then 'No especificado'
            else caja.modeloCaja
        end as modeloCaja : String,
        avg(promedioKm) as rendimiento: Decimal(10,2),
        max(promedioKm) as rendimientoMaximo: Decimal(10,2),
    }group by $self.modeloCaja;

    @odata.draft.enabled: false
    define view PerformancePerRubro as select from Viajes {
        key case 
            when rubro.name is null then 'No especificado'
            else rubro.name
        end as rubro : String,
        count (ID) as cantidad: Integer,
        avg(kilometrosPorLitro) as rendimiento: Decimal(10,2),
        max(kilometrosPorLitro) as rendimientoMaximo: Decimal(10,2),
    }group by $self.rubro;

    @odata.draft.enabled: false
    define view ViajesPorRutaSum as select from Viajes {
        key ruta.descripcion as ruta,
        'Viajes' as unitViajes: String,
        'km' as unitKm: String,
        count(ID) as cantidadViajes: Integer,
        sum(ruta.distanciaKm) as distanciaRecorrida: Decimal(10,2)
    } group by $self.ruta;

    @odata.draft.enabled: false
    define view ViajesPorRutaTiempo as select from Viajes {
        key ruta.descripcion as ruta,
        count(ID) as cantidadViajes: Integer,
        sum(ruta.distanciaKm) as distanciaRecorrida: Decimal(10,2),
        //campo para mes en que se realizo el viaje
        SUBSTR(fecha, 1, 4) AS anio: String,
        SUBSTR(fecha, 6, 2) AS mes2: String,
    }

    @odata.draft.enabled: false
    define view ViajesPorMes as select from Viajes{
        count(ID) as cantidadViajes: Integer,
        sum(ruta.distanciaKm) as distanciaRecorrida: Decimal(10,2),
        //campo para mes en que se realizo el viaje
        SUBSTR(fecha, 1, 4) AS anio: Integer,
        SUBSTR(fecha, 6, 2) AS mes: Integer,
        case
            when $self.mes = '01' then 'Enero'
            when $self.mes = '02' then 'Febrero'
            when $self.mes = '03' then 'Marzo'
            when $self.mes = '04' then 'Abril'
            when $self.mes = '05' then 'Mayo'
            when $self.mes = '06' then 'Junio'
            when $self.mes = '07' then 'Julio'
            when $self.mes = '08' then 'Agosto'
            when $self.mes = '09' then 'Septiembre'
            when $self.mes = '10' then 'Octubre'
            when $self.mes = '11' then 'Noviembre'
            else 'Diciembre'
        end as nombreMes: String,
        key ($self.anio || ' ' || $self.nombreMes) as fechaText: String
    }group by $self.fechaText order by $self.anio, $self.mes;

    @odata.draft.enabled: false
    define view ViajesPorAnio as select from Viajes{
        count(ID) as cantidadViajes: Integer,
        sum(ruta.distanciaKm) as distanciaRecorrida: Decimal(10,2),
        //campo para año en que se realizo el viaje
        key SUBSTR(fecha, 1, 4) AS anio: String
    } group by $self.anio order by $self.anio;

    @odata.draft.enabled: false
    define view ViajesPorTrimestre as select from Viajes{
        count(ID) as cantidadViajes: Integer,
        sum(ruta.distanciaKm) as distanciaRecorrida: Decimal(10,2),
        SUBSTR(fecha, 1, 4) AS anio: String,
        //campo para trimestre en que se realizo el viaje
        case 
            when SUBSTR(fecha, 6, 2) in ('01', '02', '03') then 'Q1'
            when SUBSTR(fecha, 6, 2) in ('04', '05', '06') then 'Q2'
            when SUBSTR(fecha, 6, 2) in ('07', '08', '09') then 'Q3'
            else 'Q4'
        end as trimestre: String,
        key ($self.anio || ' ' || $self.trimestre) as fechaText: String
    } group by $self.fechaText order by $self.fechaText;
    

    
}
