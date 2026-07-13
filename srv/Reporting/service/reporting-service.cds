using { gas.reporting } from '../../../db/Reporting/index';

service ReportingService {

  // Hecho principal (List Report)
  @readonly
  entity HechosViaje as projection on reporting.HechoViaje;

  // Dimensiones (para filtros y ValueHelp)
  @readonly
  entity DimensionTiempo as projection on reporting.DimTiempo;

  @readonly
  entity DimensionVehiculo as projection on reporting.DimVehiculo;

  @readonly
  entity DimensionChofer as projection on reporting.DimChofer;

  @readonly
  entity DimensionRuta as projection on reporting.DimRuta;

  @readonly
  entity DimensionProveedor as projection on reporting.DimProveedor;

  @readonly
  entity DimensionAlmacen as projection on reporting.DimAlmacen;

  // Vistas agregadas (para gráficos y KPIs)
  @readonly
  entity AggMensual as projection on reporting.V_AggMensual;

  @readonly
  entity AggPorVehiculoRuta as projection on reporting.V_AggPorVehiculoRuta;

  @readonly
  entity AggPorChofer as projection on reporting.V_AggPorChofer;

  @readonly
  entity AggPorComponente as projection on reporting.V_AggPorComponente;

  // Action: sincronizar tabla de hechos
  action sincronizar() returns {
    sincronizados : Integer;
  };

  // Actions stub para minería de datos
  action predecirConsumo(
    vehiculo_ID : UUID,
    ruta_ID     : UUID,
    pesoTotal   : Decimal(10,2)
  ) returns {
    consumoEstimado : Decimal(10,2);
    confianzaPct    : Decimal(5,2);
    modeloUsado     : String;
  };

  action clusterizarRutas() returns array of {
    clusterID       : Integer;
    descripcion     : String;
    cantidadRutas   : Integer;
    distanciaPromedio : Decimal(10,2);
    rendimientoPromedio : Decimal(10,2);
  };
}
