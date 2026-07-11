using { managed, cuid } from '@sap/cds/common';
using { gas.app.Tanque } from '../Tanques/tanques-schema';

namespace gas.app;

entity Almacen : managed, cuid {
  nombreSede       : String;
  ubicacion        : String;
  responsable      : String;
  tipo_combustible : String default 'Diesel';
  capacidadTotal   : Decimal(10,2);
  estado           : String enum {
    Activo;
    EnMantenimiento;
    Cerrado;
  };
  tanques        : Composition of many Tanque on tanques.almacen = $self;
}


