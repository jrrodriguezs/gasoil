namespace gas.reporting;

using { gas.reporting.HechoViaje } from './hecho-viaje';

@Analytics.dataCategory: #AGGREGATION
entity V_AggMensual as select from HechoViaje {
  key anio,
  key mes,
  key nombreMes,
      periodoYMD,
      count(*)              as cantidadViajes      : Integer,
      sum(distanciaKm)      as distanciaTotalKm    : Decimal(12,2),
      sum(consumoRealTotal) as combustibleRealTotal : Decimal(12,2),
      sum(consumoTeoricoTotal) as combustibleTeoricoTotal : Decimal(12,2),
      sum(costoTeorico)     as costoTotal          : Decimal(12,2),
      avg(rendimientoReal)  as rendimientoPromedio : Decimal(10,2),
      avg(variacionRendimientoPct) as variacionPromedioPct : Decimal(5,2),
      sum(toneladasPorKm)   as toneladasKmTotal    : Decimal(12,2)
} where esFinalizado = true
  group by anio, mes, nombreMes, periodoYMD;

@Analytics.dataCategory: #AGGREGATION
entity V_AggPorVehiculoRuta as select from HechoViaje {
  key placaVehiculo,
  key descripcionRuta,
      count(*)              as cantidadViajes      : Integer,
      sum(distanciaKm)      as distanciaTotalKm    : Decimal(12,2),
      avg(rendimientoReal)  as rendimientoPromedio : Decimal(10,2),
      avg(variacionRendimientoPct) as variacionPromedio : Decimal(5,2),
      sum(costoTeorico)     as costoTotal          : Decimal(12,2)
} where esFinalizado = true
  group by placaVehiculo, descripcionRuta;

@Analytics.dataCategory: #AGGREGATION
entity V_AggPorChofer as select from HechoViaje {
  key nombreChofer,
  key cedulaChofer,
      count(*)              as cantidadViajes      : Integer,
      sum(distanciaKm)      as distanciaTotalKm    : Decimal(12,2),
      avg(rendimientoReal)  as rendimientoPromedio : Decimal(10,2),
      avg(variacionRendimientoPct) as variacionPromedio : Decimal(5,2),
      sum(costoTeorico)     as costoTotal          : Decimal(12,2),
      sum(case when cumpleRendimientoTeorico then 1 else 0 end) as viajesExitosos : Integer,
      (100.0 * sum(case when cumpleRendimientoTeorico then 1 else 0 end)) / count(*) as tasaExitoPct : Decimal(5,2)
} where esFinalizado = true
  group by nombreChofer, cedulaChofer;

@Analytics.dataCategory: #AGGREGATION
entity V_AggPorComponente as select from HechoViaje {
  key motor_ID,
  key transmision_ID,
  key caja_ID,
      placaVehiculo,
      count(*)              as cantidadViajes      : Integer,
      avg(rendimientoReal)  as rendimientoPromedio : Decimal(10,2),
      avg(pesoTotal)        as pesoPromedio        : Decimal(10,2),
      avg(costoPorKm)       as costoPromedioPorKm  : Decimal(10,2)
} where esFinalizado = true
  group by motor_ID, transmision_ID, caja_ID, placaVehiculo;
