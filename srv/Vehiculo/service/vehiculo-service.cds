using { gas.app.Vehiculo } from '../../../db/Vehiculo/vehiculo-schema';
using { gas.app.Vehiculo as DbVehiculo } from '../../../db/schema';
using { gas.app.Viaje } from '../../../db/Viaje/viaje-schema';

using { gas.common.ConfiguracionCamion, gas.common.EjesCamion, gas.common.NumeroTanques as DbNumeroTanques } from '../../../db/common';
using from '../../config-service';

extend service ConfigService with {
  @cds.redirection.target : true
  @odata.draft.enabled
  entity Vehiculos as projection on DbVehiculo {
    *,
    (select sum(ruta.distanciaKm) from Viaje where vehiculo.ID = DbVehiculo.ID) as kmTotales : Decimal(10,2),
    (select sum(consumoRealTotal) from Viaje where vehiculo.ID = DbVehiculo.ID) as litrosTotales   : Decimal(10,2),
    (select round(sum(ruta.distanciaKm) / sum(consumoRealTotal),2) from Viaje where vehiculo.ID = DbVehiculo.ID) as promedioKm   : Decimal(10,2) 
  };



  entity ConfiguracionCamiones as projection on ConfiguracionCamion;
  entity EjesCamiones as projection on EjesCamion;
  entity NumeroTanquesVH as projection on DbNumeroTanques;

  function VehiculoPorPlaca(placa: String) returns Vehiculos;
}
