using { managed } from '@sap/cds/common';
using {  gas.app.Vehiculo } from '../Vehiculo/vehiculo-schema';
using { gas.app.Chofer } from '../Chofer/chofer-schema';
using { gas.app.Ruta as Ruta } from '../Ruta/ruta-schema';
using { gas.common.EstadoViaje } from '../common';
using { gas.app.Telemetria as Telemetria } from '../Telemetria/telemetria-schema';
using { gas.app.Proveedor as Proveedor } from '../Proveedor/proveedor-schema';
using { gas.app.Rubros as Rubros } from '../Rubro/rubro-schema';

namespace gas.app;
@odata.draft.bypass
entity Viaje : managed {
  key ID              : UUID;
  vehiculo            : Association to Vehiculo;
  chofer              : Association to Chofer;
  ruta                : Association to Ruta;
  fecha               : Date;
  horaSalida          : DateTime;
  horaLlegada         : DateTime;
  horaLlegadaReal     : DateTime;
  kilometrosRecorridos: Decimal(10,2);
  minHoraSalida       : DateTime @cds.persistence.skip;
  litrosSalida        : Decimal(10,2);
  pesoCarga           : Decimal(10,2);
  consumoRealTotal    : Decimal(10,2);
  consumoTeoricoTotal : Decimal(10,2); // Resultado de Distancia / (Rendimiento * Factor)
  kilometrosPorLitro  : Decimal(5,2);  // Calculado con velocidad > 5 km/h
  horasPorLitro       : Decimal(5,2);  // Calculado con velocidad < 5 km/h
  estatus             : String default 'Programado';
  estatusRef          : Association to EstadoViaje on estatusRef.code = estatus;
  logs                : Composition of many Telemetria on logs.viaje = $self;
  proveedor           : Association to Proveedor;

  rendimientoTeorico  : Decimal(10,2);
  combustibleTeorico  : Decimal(10,2);
  costoTeorico        : Decimal(10,2); 
  rubro               : Association to Rubros;
  pesoIda             : Decimal(10,2);
  pesoVuelta          : Decimal(10,2);
}
