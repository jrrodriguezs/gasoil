namespace gas.reporting;

@Analytics.dataCategory: #FACT
entity HechoViaje {
  // Claves naturales
  key viaje_ID           : UUID;
      vehiculo_ID        : UUID;
      chofer_ID          : UUID;
      ruta_ID            : UUID;
      motor_ID           : UUID;
      transmision_ID     : UUID;
      caja_ID            : UUID;
      proveedor_ID       : UUID;
      almacen_ID         : UUID;            // placeholder, nulo por ahora
      rubro_ID           : UUID;

  // Dimensiones resueltas
      placaVehiculo      : String;
      modeloVehiculo     : String;
      nombreChofer       : String;
      cedulaChofer       : String;
      descripcionRuta    : String;
      nombreProveedor    : String;
      nombreAlmacen      : String;            // placeholder, nulo por ahora
      nombreRubro        : String;

  // Dimensión Tiempo
      fechaKey           : String(8);
      fecha              : Date;
      anio               : Integer;
      mes                : Integer;
      trimestre          : Integer;
      semanaAnio         : Integer;
      diaSemana          : Integer;
      nombreMes          : String;
      esFinDeSemana      : Boolean;
      periodoYMD         : String(6);
      periodoYQT         : String(7);

  // Métricas de distancia y tiempo
      distanciaKm        : Decimal(10,2);
      kilometrosRecorridos : Decimal(10,2);
      horasSalida        : DateTime;
      horasLlegada       : DateTime;
      horasLlegadaReal   : DateTime;
      duracionHoras      : Decimal(5,2);
      duracionTeoricaHoras : Decimal(5,2);

  // Métricas de combustible
      litrosSalida       : Decimal(10,2);
      consumoRealTotal   : Decimal(10,2);
      consumoTeoricoTotal : Decimal(10,2);
      combustibleTeorico : Decimal(10,2);
      costoTeorico       : Decimal(10,2);
      precioCombustible  : Decimal(10,2);

  // Métricas de rendimiento
      rendimientoReal    : Decimal(10,2);
      rendimientoTeorico : Decimal(10,2);
      variacionRendimientoPct : Decimal(5,2);
      kilometrosPorLitro : Decimal(5,2);
      horasPorLitro      : Decimal(5,2);

  // Métricas de carga
      pesoCarga          : Decimal(10,2);
      pesoIda            : Decimal(10,2);
      pesoVuelta         : Decimal(10,2);
      pesoTotal          : Decimal(10,2);
      toneladasPorKm     : Decimal(10,2);

  // Flags calculados
      estadoViaje        : String;
      esFinalizado       : Boolean;
      esCancelado        : Boolean;
      cumpleRendimientoTeorico : Boolean;
      esSobrecarga       : Boolean;
      esViajeCorto       : Boolean;
      esViajeLargo       : Boolean;
      eficienciaCategoria : String;
      costoPorKm         : Decimal(10,2);
      costoPorToneladaKm : Decimal(10,4);

  // Métricas de telemetría
      velocidadPromedio  : Decimal(5,2);
      velocidadMaxima    : Decimal(5,2);
      altitudPromedio    : Decimal(6,2);
      registrosTelemetria : Integer;

  // Criticality para UI
      variacionCriticality : Integer;

  // Auditoría
      createdAt          : Timestamp;
      modifiedAt         : Timestamp;
}
