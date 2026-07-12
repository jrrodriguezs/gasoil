using { managed } from '@sap/cds/common';
using { gas.app.Chofer  } from '../Chofer/chofer-schema';
using { gas.app.Caja } from '../Caja/caja-schema';
using { gas.app.Transmision } from '../Transmision/transmision-schema';
using { gas.app.Viaje } from '../Viaje/viaje-schema';
using { gas.app.Motor } from '../Motor/motor-schema';
using { gas.common.VH_State, gas.common.EjesCamion, gas.common.NumeroTanques, gas.common.MedicionGaso } from '../common';
using { cuid } from '@sap/cds/common';

namespace gas.app;

aspect VehiculoRequired  {
  @assert.unique
  @mandatory @assert.notNull placa            : String;
  @mandatory @assert.notNull modelo            : String;
  @mandatory @assert.notNull numeroTanques     : Integer;
  @mandatory @assert.notNull capacidadTanque1  : Decimal(10,2);
  @mandatory @assert.notNull configuraciondelremolque : String;
}

entity Vehiculo : managed,  cuid, VehiculoRequired {
  imageVehiculo             : String; 
  tipo_combustible          : String default 'Diesel';
  motor                     : Association to Motor;
  nivelActualCombustible     :  Decimal(10,2);
  capacidadTanque2          : Decimal(10,2) default 0;
  @readonly
  capacidadTotal            : Decimal(10,2); // Calculada automaticamente
  rendimientoBase           : Decimal(5,2) ; // Km/L nominal
  rendimientoReal           : Decimal(5,2) ;
  cargautil                 : Decimal(10,2); // Toneladas
  estadodelvehiculo         : Association to VH_State;
  ejescamion                : Association to EjesCamion;
  numeroTanquesRef          : Association to NumeroTanques on numeroTanquesRef.code = numeroTanques;
  caja                      : Association to Caja ;
  transmision               : Association to Transmision;
  chofer                    : Association to Chofer;
  viajes                    : Association to many Viaje on viajes.vehiculo = $self;
  measure                   : Association to MedicionGaso;
};