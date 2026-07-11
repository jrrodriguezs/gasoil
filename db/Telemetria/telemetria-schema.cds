using { gas.app.Viaje } from '../Viaje/viaje-schema';

entity Telemetria {
  key ID               : UUID;
  timestamp            : DateTime;
  nivelCombustible     : Decimal(10,2); // Suma T1 + T2
  velocidad            : Decimal(5,2);
  altitud              : Decimal(6,2);  // Para API de Elevacion
  latitud              : Decimal(12,9);
  longitud             : Decimal(12,9);
  viaje                : Association to Viaje;
}
