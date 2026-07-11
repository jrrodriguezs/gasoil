using { gas.app.Tanque as DbTanques } from '../../../db/Tanques/tanques-schema';
using { gas.common.VH_State as TanqueEstado } from '../../../db/common';
using { gas.app.Tanque as DbTanque } from '../../../db/schema';
using from '../../config-service';

extend service ConfigService with {
  @cds.redirection.target : true
  entity Tanques as projection on DbTanque { * };
  entity TanqueEstados as projection on TanqueEstado;
};
