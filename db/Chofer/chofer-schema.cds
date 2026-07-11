using { gas.app.Vehiculo } from '../Vehiculo/vehiculo-schema';
using { gas.app.Viaje } from '../Viaje/viaje-schema';
using { cuid , sap.common.CodeList} from '@sap/cds/common';
using { managed } from '@sap/cds/common';

namespace gas.app;

aspect ChoferRequired {
  @mandatory nombre                                    : String;
  @mandatory apellido                                  : String;
  @assert.unique @mandatory @assert.ranger cedula      : String;
  @mandatory direccion                                 : String;
  @mandatory 
  telefono                                             : String @assert.range : { minimum: 11, message: 'El teléfono del chofer debe tener al menos 11 dígitos' };
  rendimiento                                          : Association to Rendimiento;
}

entity Chofer : managed, cuid, ChoferRequired {
  choferImage        : String;
  vehiculosAsignados : Association to many Vehiculo on vehiculosAsignados.chofer = $self;
  vehiculo           : Association to Vehiculo;
  viajes             : Association to many Viaje on viajes.chofer = $self;
}

entity Rendimiento : CodeList {
  key  code : String enum {
    Bueno;
    Malo;
    Regular
  };
  name         : String @UI : { Hidden};
  descr        : String @UI : { Hidden};
  criticality  : Integer;
  qualifier    : Double;
}