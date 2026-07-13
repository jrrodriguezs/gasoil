using { gas.common.VH_State as TanqueEstado } from '../../../db/common';
using { gas.app.Tanque as DbTanque } from '../../../db/schema';
using from '../../config-service';

extend service ConfigService with {
  @cds.redirection.target : true
  entity Tanques as projection on DbTanque {
    *,
    case
      when nivel_actual <= nivel_minimo then 1
      when nivel_actual <= (nivel_minimo * 1.5) then 2
      else 3
    end as nivelCriticality : Integer
  };
  entity TanqueEstados as projection on TanqueEstado;
};
