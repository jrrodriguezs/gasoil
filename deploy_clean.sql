[36m[cds-plugin-ui5][0m [32m[INFO][0m Running cds-plugin-ui5@0.13.6 (@sap/cds-dk@10.0.3, @sap/cds@9.9.2)
DROP VIEW IF EXISTS ConfigService_DriverRating;
DROP VIEW IF EXISTS ConfigService_CostoCombustiblePromedio;
DROP VIEW IF EXISTS ReportingService_AggPorComponente;
DROP VIEW IF EXISTS ReportingService_AggPorChofer;
DROP VIEW IF EXISTS ReportingService_AggPorVehiculoRuta;
DROP VIEW IF EXISTS ReportingService_AggMensual;
DROP VIEW IF EXISTS ReportingService_DescripcionesRuta;
DROP VIEW IF EXISTS ReportingService_NombresChofer;
DROP VIEW IF EXISTS ReportingService_ModelosVehiculo;
DROP VIEW IF EXISTS ReportingService_PlacasVehiculo;
DROP VIEW IF EXISTS ConfigService_ViajesPorTrimestre;
DROP VIEW IF EXISTS ConfigService_ViajesPorAnio;
DROP VIEW IF EXISTS ConfigService_ViajesPorMes;
DROP VIEW IF EXISTS ConfigService_ViajesPorRutaTiempo;
DROP VIEW IF EXISTS ConfigService_ViajesPorRutaSum;
DROP VIEW IF EXISTS ConfigService_PerformancePerRubro;
DROP VIEW IF EXISTS ConfigService_PerformacePerCaja;
DROP VIEW IF EXISTS ConfigService_PerformacePerTransmision;
DROP VIEW IF EXISTS ConfigService_PerformacePerMotor;
DROP VIEW IF EXISTS ConfigService_DriverPerformance;
DROP VIEW IF EXISTS ConfigService_PerformancePlannedVSReal;
DROP VIEW IF EXISTS ConfigService_TankCritical;
DROP VIEW IF EXISTS ConfigService_UltimoPrecioCombustibleProveedor;
DROP VIEW IF EXISTS ConfigService_TankPerStatus;
DROP VIEW IF EXISTS ConfigService_VehiclePerStatus;
DROP VIEW IF EXISTS ConfigService_PerformancePerWeight;
DROP VIEW IF EXISTS ConfigService_PerformancePerRoute;
DROP VIEW IF EXISTS ConfigService_TankCapacity;
DROP VIEW IF EXISTS ConfigService_PerformanceByModel;
DROP VIEW IF EXISTS ConfigService_PerformanceAvg;
DROP VIEW IF EXISTS ConfigService_PerformacePerVehicle;
DROP VIEW IF EXISTS ConfigService_DraftAdministrativeData;
DROP VIEW IF EXISTS gas_reporting_V_AggPorComponente;
DROP VIEW IF EXISTS gas_reporting_V_AggPorChofer;
DROP VIEW IF EXISTS gas_reporting_V_AggPorVehiculoRuta;
DROP VIEW IF EXISTS gas_reporting_V_AggMensual;
DROP VIEW IF EXISTS gas_reporting_V_DescripcionesRuta;
DROP VIEW IF EXISTS gas_reporting_V_NombresChofer;
DROP VIEW IF EXISTS gas_reporting_V_ModelosVehiculo;
DROP VIEW IF EXISTS gas_reporting_V_PlacasVehiculo;
DROP VIEW IF EXISTS ReportingService_Transmisiones;
DROP VIEW IF EXISTS ReportingService_VH_State;
DROP VIEW IF EXISTS ReportingService_TipoEmisiones;
DROP VIEW IF EXISTS ReportingService_ModeloMotor;
DROP VIEW IF EXISTS ReportingService_Motores;
DROP VIEW IF EXISTS ReportingService_DimensionAlmacen;
DROP VIEW IF EXISTS ReportingService_DimensionProveedor;
DROP VIEW IF EXISTS ReportingService_DimensionRuta;
DROP VIEW IF EXISTS ReportingService_DimensionChofer;
DROP VIEW IF EXISTS ReportingService_DimensionVehiculo;
DROP VIEW IF EXISTS ReportingService_DimensionTiempo;
DROP VIEW IF EXISTS ReportingService_HechosViajeReportes;
DROP VIEW IF EXISTS ReportingService_HechosViaje;
DROP VIEW IF EXISTS ConfigService_TanquesDisponibles;
DROP VIEW IF EXISTS ConfigService_SurtidosUnidad;
DROP VIEW IF EXISTS ConfigService_TankXOrden;
DROP VIEW IF EXISTS ConfigService_OrdenesCarga;
DROP VIEW IF EXISTS ConfigService_Tanques;
DROP VIEW IF EXISTS ConfigService_Almacenes;
DROP VIEW IF EXISTS ConfigService_ConfiguracionCamiones;
DROP VIEW IF EXISTS ConfigService_MedicionesGaso;
DROP VIEW IF EXISTS ConfigService_Rubros;
DROP VIEW IF EXISTS ConfigService_PreciosHistoricos;
DROP VIEW IF EXISTS ConfigService_Proveedores;
DROP VIEW IF EXISTS ConfigService_Telemetrias;
DROP VIEW IF EXISTS ConfigService_EstadoViajes;
DROP VIEW IF EXISTS ConfigService_PuntoCoordenadas;
DROP VIEW IF EXISTS ConfigService_Rutas;
DROP VIEW IF EXISTS ConfigService_Viajes;
DROP VIEW IF EXISTS ConfigService_Transmisiones;
DROP VIEW IF EXISTS ConfigService_Cajas;
DROP VIEW IF EXISTS ConfigService_NumeroTanquesVH;
DROP VIEW IF EXISTS ConfigService_EjesCamiones;
DROP VIEW IF EXISTS ConfigService_TanqueEstados;
DROP VIEW IF EXISTS ConfigService_TipoEmisiones;
DROP VIEW IF EXISTS ConfigService_ModeloMotor;
DROP VIEW IF EXISTS ConfigService_Motores;
DROP VIEW IF EXISTS ConfigService_Vehiculos;
DROP VIEW IF EXISTS ConfigService_Rendimiento;
DROP VIEW IF EXISTS ConfigService_Choferes;
DROP TABLE IF EXISTS ConfigService_SurtidosUnidad_drafts;
DROP TABLE IF EXISTS ConfigService_TankXOrden_drafts;
DROP TABLE IF EXISTS ConfigService_OrdenesCarga_drafts;
DROP TABLE IF EXISTS ConfigService_Tanques_drafts;
DROP TABLE IF EXISTS ConfigService_Almacenes_drafts;
DROP TABLE IF EXISTS ConfigService_Rubros_drafts;
DROP TABLE IF EXISTS ConfigService_PreciosHistoricos_drafts;
DROP TABLE IF EXISTS ConfigService_Proveedores_drafts;
DROP TABLE IF EXISTS ConfigService_PuntoCoordenadas_drafts;
DROP TABLE IF EXISTS ConfigService_Rutas_drafts;
DROP TABLE IF EXISTS ConfigService_Telemetrias_drafts;
DROP TABLE IF EXISTS ConfigService_Viajes_drafts;
DROP TABLE IF EXISTS ConfigService_Transmisiones_drafts;
DROP TABLE IF EXISTS ConfigService_Cajas_drafts;
DROP TABLE IF EXISTS ConfigService_Motores_drafts;
DROP TABLE IF EXISTS ConfigService_Vehiculos_drafts;
DROP TABLE IF EXISTS ConfigService_Choferes_drafts;
DROP TABLE IF EXISTS DRAFT_DraftAdministrativeData;
DROP TABLE IF EXISTS cds_outbox_Messages;
DROP TABLE IF EXISTS gas_reporting_DimAlmacen;
DROP TABLE IF EXISTS gas_reporting_DimProveedor;
DROP TABLE IF EXISTS gas_reporting_DimRuta;
DROP TABLE IF EXISTS gas_reporting_DimChofer;
DROP TABLE IF EXISTS gas_reporting_DimVehiculo;
DROP TABLE IF EXISTS gas_reporting_DimTiempo;
DROP TABLE IF EXISTS gas_reporting_HechoViaje;
DROP TABLE IF EXISTS gas_app_SurtidoUnidad;
DROP TABLE IF EXISTS gas_app_TankXOrden;
DROP TABLE IF EXISTS gas_app_OrdenCarga;
DROP TABLE IF EXISTS gas_app_Tanque;
DROP TABLE IF EXISTS gas_app_Almacen;
DROP TABLE IF EXISTS gas_common_ConfiguracionCamion;
DROP TABLE IF EXISTS gas_common_MedicionGaso;
DROP TABLE IF EXISTS gas_app_Rubros;
DROP TABLE IF EXISTS gas_app_PrecioHistorico;
DROP TABLE IF EXISTS gas_app_Proveedor;
DROP TABLE IF EXISTS gas_app_Telemetria;
DROP TABLE IF EXISTS gas_common_EstadoViaje;
DROP TABLE IF EXISTS gas_app_PuntoCoordenada;
DROP TABLE IF EXISTS gas_app_Ruta;
DROP TABLE IF EXISTS gas_app_Viaje;
DROP TABLE IF EXISTS gas_app_Transmision;
DROP TABLE IF EXISTS gas_app_Caja;
DROP TABLE IF EXISTS gas_common_NumeroTanques;
DROP TABLE IF EXISTS gas_common_EjesCamion;
DROP TABLE IF EXISTS gas_common_VH_State;
DROP TABLE IF EXISTS gas_common_TipoEmisiones;
DROP TABLE IF EXISTS gas_common_ModeloMotor;
DROP TABLE IF EXISTS gas_app_Motor;
DROP TABLE IF EXISTS gas_app_Vehiculo;
DROP TABLE IF EXISTS gas_app_Rendimiento;
DROP TABLE IF EXISTS gas_app_Chofer;
CREATE TABLE gas_app_Chofer (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  nombre VARCHAR(255),
  apellido VARCHAR(255),
  cedula VARCHAR(255),
  direccion VARCHAR(255),
  telefono VARCHAR(255),
  rendimiento_code VARCHAR(255),
  choferImage VARCHAR(255),
  vehiculo_ID VARCHAR(36),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_Rendimiento (
  code VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  descr VARCHAR(255),
  criticality INTEGER,
  qualifier FLOAT8,
  PRIMARY KEY(code)
);
CREATE TABLE gas_app_Vehiculo (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  placa VARCHAR(255),
  modelo VARCHAR(255),
  numeroTanques INTEGER,
  capacidadTanque1 DECIMAL(10, 2),
  configuraciondelremolque VARCHAR(255),
  imageVehiculo VARCHAR(255),
  tipo_combustible VARCHAR(255) DEFAULT 'Diesel',
  motor_ID VARCHAR(36),
  nivelActualCombustible DECIMAL(10, 2),
  capacidadTanque2 DECIMAL(10, 2) DEFAULT 0,
  capacidadTotal DECIMAL(10, 2),
  rendimientoBase DECIMAL(5, 2),
  rendimientoReal DECIMAL(5, 2),
  cargautil DECIMAL(10, 2),
  estadodelvehiculo_code VARCHAR(255),
  ejescamion_code VARCHAR(255),
  caja_ID VARCHAR(36),
  transmision_ID VARCHAR(36),
  chofer_ID VARCHAR(36),
  measure_code VARCHAR(255),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_Motor (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  modelo_code VARCHAR(255),
  serie VARCHAR(255),
  factorEficiencia FLOAT8,
  torqueMax FLOAT8,
  cilindrada FLOAT8,
  tipoEmision_code VARCHAR(255),
  estado_code VARCHAR(255),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_common_ModeloMotor (
  code VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  descr VARCHAR(255),
  PRIMARY KEY(code)
);
CREATE TABLE gas_common_TipoEmisiones (
  code VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  descr VARCHAR(255),
  requiereUrea BOOLEAN,
  requiereAceiteSintetico BOOLEAN,
  sensibilidadGasoil VARCHAR(255),
  PRIMARY KEY(code)
);
CREATE TABLE gas_common_VH_State (
  code VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  descr VARCHAR(255),
  criticality INTEGER,
  PRIMARY KEY(code)
);
CREATE TABLE gas_common_EjesCamion (
  code VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  descr VARCHAR(255),
  PRIMARY KEY(code)
);
CREATE TABLE gas_common_NumeroTanques (
  code INTEGER NOT NULL,
  name VARCHAR(255),
  descr VARCHAR(255),
  PRIMARY KEY(code)
);
CREATE TABLE gas_app_Caja (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  modeloCaja VARCHAR(255),
  numeroVelocidades INTEGER,
  factorTransmision FLOAT8,
  estado_code VARCHAR(255),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_Transmision (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  modeloDiferencial VARCHAR(255),
  relacionTransmision FLOAT8,
  factorTransmision FLOAT8,
  tipoEje VARCHAR(255),
  capacidadCargaEje FLOAT8,
  estado_code VARCHAR(255),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_Viaje (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  vehiculo_ID VARCHAR(36),
  chofer_ID VARCHAR(36),
  ruta_ID VARCHAR(36),
  fecha DATE,
  horaSalida TIMESTAMP,
  horaLlegada TIMESTAMP,
  horaLlegadaReal TIMESTAMP,
  kilometrosRecorridos DECIMAL(10, 2),
  minHoraSalida TIMESTAMP,
  litrosSalida DECIMAL(10, 2),
  pesoCarga DECIMAL(10, 2),
  consumoRealTotal DECIMAL(10, 2),
  consumoTeoricoTotal DECIMAL(10, 2),
  kilometrosPorLitro DECIMAL(5, 2),
  horasPorLitro DECIMAL(5, 2),
  estatus VARCHAR(255) DEFAULT 'Programado',
  proveedor_ID VARCHAR(36),
  rendimientoTeorico DECIMAL(10, 2),
  combustibleTeorico DECIMAL(10, 2),
  costoTeorico DECIMAL(10, 2),
  rubro_ID VARCHAR(36),
  pesoIda DECIMAL(10, 2),
  pesoVuelta DECIMAL(10, 2),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_Ruta (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  descripcion VARCHAR(255),
  distanciaKm DECIMAL(10, 2),
  latitud DECIMAL(9, 6),
  longitud DECIMAL(9, 6),
  destinosCount INTEGER,
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_PuntoCoordenada (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  latitud DECIMAL(9, 6),
  longitud DECIMAL(9, 6),
  descripcion VARCHAR(255),
  ruta_ID VARCHAR(36),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_common_EstadoViaje (
  code VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  descr VARCHAR(255),
  PRIMARY KEY(code)
);
CREATE TABLE gas_app_Telemetria (
  ID VARCHAR(36) NOT NULL,
  timestamp TIMESTAMP,
  nivelCombustible DECIMAL(10, 2),
  velocidad DECIMAL(5, 2),
  altitud DECIMAL(6, 2),
  latitud DECIMAL(12, 9),
  longitud DECIMAL(12, 9),
  viaje_ID VARCHAR(36),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_Proveedor (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  nombre VARCHAR(255),
  telefono VARCHAR(255),
  capacidad_despacho DECIMAL(10, 2),
  direccion VARCHAR(255),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_PrecioHistorico (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  proveedor_ID VARCHAR(36),
  precioCombustible DECIMAL(10, 2),
  precio DECIMAL(10, 2),
  litros_distribuidos DECIMAL(10, 2),
  fecha DATE,
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_Rubros (
  ID VARCHAR(36) NOT NULL,
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  name VARCHAR(50),
  description VARCHAR(255),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_common_MedicionGaso (
  code VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  descr VARCHAR(255),
  PRIMARY KEY(code)
);
CREATE TABLE gas_common_ConfiguracionCamion (
  code VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  descr VARCHAR(255),
  PRIMARY KEY(code)
);
CREATE TABLE gas_app_Almacen (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  nombreSede VARCHAR(255),
  ubicacion VARCHAR(255),
  responsable VARCHAR(255),
  tipo_combustible VARCHAR(255) DEFAULT 'Diesel',
  capacidadTotal DECIMAL(10, 2),
  estado VARCHAR(255),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_Tanque (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  codigo VARCHAR(255),
  almacen_ID VARCHAR(36),
  tipo_combustible VARCHAR(255) DEFAULT 'Diesel',
  capacidadTotal DECIMAL(10, 2),
  nivel_minimo DECIMAL(10, 2),
  nivel_actual DECIMAL(10, 2),
  ultimaFechaRecarga DATE,
  descripcion VARCHAR(255),
  estadoTanque_code VARCHAR(255),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_OrdenCarga (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  fechaCarga TIMESTAMP,
  proveedor_ID VARCHAR(36),
  tanque_ID VARCHAR(36),
  placaCamionCisterna VARCHAR(255),
  nombreChoferCisterna VARCHAR(255),
  cedulaChoferCisterna VARCHAR(255),
  carga_real DECIMAL(10, 2),
  placa_vehiculo VARCHAR(255),
  cedula_chofer VARCHAR(255),
  carga_facturada DECIMAL(10, 2),
  observacion VARCHAR(255),
  variacion DECIMAL(10, 2),
  porcentaje_conciliacion DECIMAL(5, 2),
  isFirst BOOLEAN,
  almacen_ID VARCHAR(36),
  precio FLOAT8,
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_TankXOrden (
  ID VARCHAR(36) NOT NULL,
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  orden_ID VARCHAR(36),
  tanque_ID VARCHAR(36),
  quantity DECIMAL(10, 2),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_app_SurtidoUnidad (
  createdAt TIMESTAMP,
  createdBy VARCHAR(255),
  modifiedAt TIMESTAMP,
  modifiedBy VARCHAR(255),
  ID VARCHAR(36) NOT NULL,
  fechaCarga TIMESTAMP,
  vehiculo_ID VARCHAR(36),
  tanque_ID VARCHAR(36),
  carga_real DECIMAL(10, 2),
  volumenPrevioVehiculo DECIMAL(10, 2),
  volumen_actual_vehiculo DECIMAL(10, 2),
  responsable VARCHAR(255),
  cargaExterna BOOLEAN DEFAULT FALSE,
  nombreEstacionServicio VARCHAR(255),
  precioCombustible DECIMAL(10, 2),
  almacen_ID VARCHAR(36),
  proveedor_ID VARCHAR(36),
  ordenCarga_ID VARCHAR(36),
  PRIMARY KEY(ID)
);
CREATE TABLE gas_reporting_HechoViaje (
  viaje_ID VARCHAR(36) NOT NULL,
  vehiculo_ID VARCHAR(36),
  chofer_ID VARCHAR(36),
  ruta_ID VARCHAR(36),
  motor_ID VARCHAR(36),
  transmision_ID VARCHAR(36),
  caja_ID VARCHAR(36),
  proveedor_ID VARCHAR(36),
  almacen_ID VARCHAR(36),
  rubro_ID VARCHAR(36),
  placaVehiculo VARCHAR(255),
  modeloVehiculo VARCHAR(255),
  nombreChofer VARCHAR(255),
  cedulaChofer VARCHAR(255),
  descripcionRuta VARCHAR(255),
  nombreProveedor VARCHAR(255),
  nombreAlmacen VARCHAR(255),
  nombreRubro VARCHAR(255),
  fechaKey VARCHAR(8),
  fecha DATE,
  anio INTEGER,
  mes INTEGER,
  trimestre INTEGER,
  semanaAnio INTEGER,
  diaSemana INTEGER,
  nombreMes VARCHAR(255),
  esFinDeSemana BOOLEAN,
  periodoYMD VARCHAR(6),
  periodoYQT VARCHAR(7),
  distanciaKm DECIMAL(10, 2),
  kilometrosRecorridos DECIMAL(10, 2),
  horasSalida TIMESTAMP,
  horasLlegada TIMESTAMP,
  horasLlegadaReal TIMESTAMP,
  duracionHoras DECIMAL(5, 2),
  duracionTeoricaHoras DECIMAL(5, 2),
  litrosSalida DECIMAL(10, 2),
  consumoRealTotal DECIMAL(10, 2),
  consumoTeoricoTotal DECIMAL(10, 2),
  combustibleTeorico DECIMAL(10, 2),
  costoTeorico DECIMAL(10, 2),
  precioCombustible DECIMAL(10, 2),
  rendimientoReal DECIMAL(10, 2),
  rendimientoTeorico DECIMAL(10, 2),
  variacionRendimientoPct DECIMAL(5, 2),
  kilometrosPorLitro DECIMAL(5, 2),
  horasPorLitro DECIMAL(5, 2),
  pesoCarga DECIMAL(10, 2),
  pesoIda DECIMAL(10, 2),
  pesoVuelta DECIMAL(10, 2),
  pesoTotal DECIMAL(10, 2),
  toneladasPorKm DECIMAL(10, 2),
  estadoViaje VARCHAR(255),
  esFinalizado BOOLEAN,
  esCancelado BOOLEAN,
  cumpleRendimientoTeorico BOOLEAN,
  esSobrecarga BOOLEAN,
  esViajeCorto BOOLEAN,
  esViajeLargo BOOLEAN,
  eficienciaCategoria VARCHAR(255),
  costoPorKm DECIMAL(10, 2),
  costoPorToneladaKm DECIMAL(10, 4),
  velocidadPromedio DECIMAL(5, 2),
  velocidadMaxima DECIMAL(5, 2),
  altitudPromedio DECIMAL(6, 2),
  registrosTelemetria INTEGER,
  variacionCriticality INTEGER,
  createdAt TIMESTAMP,
  modifiedAt TIMESTAMP,
  PRIMARY KEY(viaje_ID)
);
CREATE TABLE gas_reporting_DimTiempo (
  dateKey VARCHAR(8) NOT NULL,
  fecha DATE,
  anio INTEGER,
  mes INTEGER,
  dia INTEGER,
  trimestre INTEGER,
  semanaAnio INTEGER,
  diaSemana INTEGER,
  nombreMes VARCHAR(10),
  nombreDia VARCHAR(10),
  esFinDeSemana BOOLEAN DEFAULT FALSE,
  esFeriado BOOLEAN DEFAULT FALSE,
  periodoYMD VARCHAR(6),
  periodoYQT VARCHAR(7),
  diasDesdeInicioAnio INTEGER,
  diasHastaFinAnio INTEGER,
  PRIMARY KEY(dateKey)
);
CREATE TABLE gas_reporting_DimVehiculo (
  vehiculo_ID VARCHAR(36) NOT NULL,
  placa VARCHAR(255),
  modelo VARCHAR(255),
  motorModelo VARCHAR(255),
  transmisionModelo VARCHAR(255),
  cajaModelo VARCHAR(255),
  ejes VARCHAR(255),
  configuracion VARCHAR(255),
  capacidadTotal DECIMAL(10, 2),
  cargautil DECIMAL(10, 2),
  estado VARCHAR(255),
  antiguedadDias INTEGER,
  categoriaCarga VARCHAR(255),
  PRIMARY KEY(vehiculo_ID)
);
CREATE TABLE gas_reporting_DimChofer (
  chofer_ID VARCHAR(36) NOT NULL,
  nombreCompleto VARCHAR(255),
  cedula VARCHAR(255),
  rendimientoQual VARCHAR(255),
  viajesTotales INTEGER,
  experienciaMeses INTEGER,
  PRIMARY KEY(chofer_ID)
);
CREATE TABLE gas_reporting_DimRuta (
  ruta_ID VARCHAR(36) NOT NULL,
  descripcion VARCHAR(255),
  distanciaKm DECIMAL(10, 2),
  destinosCount INTEGER,
  latitud DECIMAL(9, 6),
  longitud DECIMAL(9, 6),
  puntosCount INTEGER,
  categoriaDistancia VARCHAR(255),
  complejidadRuta INTEGER,
  PRIMARY KEY(ruta_ID)
);
CREATE TABLE gas_reporting_DimProveedor (
  proveedor_ID VARCHAR(36) NOT NULL,
  nombre VARCHAR(255),
  capacidadDespacho DECIMAL(10, 2),
  precioPromedio DECIMAL(10, 2),
  PRIMARY KEY(proveedor_ID)
);
CREATE TABLE gas_reporting_DimAlmacen (
  almacen_ID VARCHAR(36) NOT NULL,
  nombreSede VARCHAR(255),
  ubicacion VARCHAR(255),
  estado VARCHAR(255),
  capacidadTotal DECIMAL(10, 2),
  tanquesCount INTEGER,
  PRIMARY KEY(almacen_ID)
);
CREATE TABLE cds_outbox_Messages (
  ID VARCHAR(36) NOT NULL,
  timestamp TIMESTAMP,
  target VARCHAR(255),
  msg TEXT,
  attempts INTEGER DEFAULT 0,
  partition INTEGER DEFAULT 0,
  lastError TEXT,
  lastAttemptTimestamp TIMESTAMP,
  status VARCHAR(23),
  task VARCHAR(255),
  appid VARCHAR(255),
  PRIMARY KEY(ID)
);
CREATE TABLE DRAFT_DraftAdministrativeData (
  DraftUUID VARCHAR(36) NOT NULL,
  CreationDateTime TIMESTAMP,
  CreatedByUser VARCHAR(256),
  CreatedByUserDescription VARCHAR(256),
  DraftIsCreatedByMe BOOLEAN,
  LastChangeDateTime TIMESTAMP,
  LastChangedByUser VARCHAR(256),
  LastChangedByUserDescription VARCHAR(256),
  InProcessByUser VARCHAR(256),
  InProcessByUserDescription VARCHAR(256),
  DraftIsProcessedByMe BOOLEAN,
  DraftMessages TEXT,
  PRIMARY KEY(DraftUUID)
);
CREATE TABLE ConfigService_Choferes_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  nombre VARCHAR(255) NULL,
  apellido VARCHAR(255) NULL,
  cedula VARCHAR(255) NULL,
  direccion VARCHAR(255) NULL,
  telefono VARCHAR(255) NULL,
  rendimiento_code VARCHAR(255) NULL,
  choferImage VARCHAR(255) NULL,
  vehiculo_ID VARCHAR(36) NULL,
  nombreCompleto VARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_Vehiculos_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  placa VARCHAR(255) NULL,
  modelo VARCHAR(255) NULL,
  numeroTanques INTEGER NULL,
  capacidadTanque1 DECIMAL(10, 2) NULL,
  configuraciondelremolque VARCHAR(255) NULL,
  imageVehiculo VARCHAR(255) NULL,
  tipo_combustible VARCHAR(255) NULL DEFAULT 'Diesel',
  motor_ID VARCHAR(36) NULL,
  nivelActualCombustible DECIMAL(10, 2) NULL,
  capacidadTanque2 DECIMAL(10, 2) NULL DEFAULT 0,
  capacidadTotal DECIMAL(10, 2) NULL,
  rendimientoBase DECIMAL(5, 2) NULL,
  rendimientoReal DECIMAL(5, 2) NULL,
  cargautil DECIMAL(10, 2) NULL,
  estadodelvehiculo_code VARCHAR(255) NULL,
  ejescamion_code VARCHAR(255) NULL,
  caja_ID VARCHAR(36) NULL,
  transmision_ID VARCHAR(36) NULL,
  chofer_ID VARCHAR(36) NULL,
  measure_code VARCHAR(255) NULL,
  kmTotales DECIMAL(10, 2) NULL,
  litrosTotales DECIMAL(10, 2) NULL,
  promedioKm DECIMAL(10, 2) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_Motores_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  modelo_code VARCHAR(255) NULL,
  serie VARCHAR(255) NULL,
  factorEficiencia FLOAT8 NULL,
  torqueMax FLOAT8 NULL,
  cilindrada FLOAT8 NULL,
  tipoEmision_code VARCHAR(255) NULL,
  estado_code VARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_Cajas_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  modeloCaja VARCHAR(255) NULL,
  numeroVelocidades INTEGER NULL,
  factorTransmision FLOAT8 NULL,
  estado_code VARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_Transmisiones_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  modeloDiferencial VARCHAR(255) NULL,
  relacionTransmision FLOAT8 NULL,
  factorTransmision FLOAT8 NULL,
  tipoEje VARCHAR(255) NULL,
  capacidadCargaEje FLOAT8 NULL,
  estado_code VARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_Viajes_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  vehiculo_ID VARCHAR(36) NULL,
  chofer_ID VARCHAR(36) NULL,
  ruta_ID VARCHAR(36) NULL,
  fecha DATE NULL,
  horaSalida TIMESTAMP NULL,
  horaLlegada TIMESTAMP NULL,
  horaLlegadaReal TIMESTAMP NULL,
  kilometrosRecorridos DECIMAL(10, 2) NULL,
  minHoraSalida TIMESTAMP NULL,
  litrosSalida DECIMAL(10, 2) NULL,
  pesoCarga DECIMAL(10, 2) NULL,
  consumoRealTotal DECIMAL(10, 2) NULL,
  consumoTeoricoTotal DECIMAL(10, 2) NULL,
  kilometrosPorLitro DECIMAL(5, 2) NULL,
  horasPorLitro DECIMAL(5, 2) NULL,
  estatus VARCHAR(255) NULL DEFAULT 'Programado',
  proveedor_ID VARCHAR(36) NULL,
  rendimientoTeorico DECIMAL(10, 2) NULL,
  combustibleTeorico DECIMAL(10, 2) NULL,
  costoTeorico DECIMAL(10, 2) NULL,
  rubro_ID VARCHAR(36) NULL,
  pesoIda DECIMAL(10, 2) NULL,
  pesoVuelta DECIMAL(10, 2) NULL,
  nombreRuta VARCHAR(255) NULL,
  choferNombreCompleto VARCHAR(255) NULL,
  vehiculoPlaca VARCHAR(255) NULL,
  vehiculoModelo VARCHAR(255) NULL,
  distanciaRuta DECIMAL(10, 2) NULL,
  rutaLatitud DECIMAL(9, 6) NULL,
  rutaLongitud DECIMAL(9, 6) NULL,
  viajesEnRuta INTEGER NULL,
  viajesVehiculoEnRuta INTEGER NULL,
  consumoUltimo1 DECIMAL(10, 2) NULL,
  consumoUltimo2 DECIMAL(10, 2) NULL,
  consumoUltimo3 DECIMAL(10, 2) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_Telemetrias_drafts (
  ID VARCHAR(36) NOT NULL,
  timestamp TIMESTAMP NULL,
  nivelCombustible DECIMAL(10, 2) NULL,
  velocidad DECIMAL(5, 2) NULL,
  altitud DECIMAL(6, 2) NULL,
  latitud DECIMAL(12, 9) NULL,
  longitud DECIMAL(12, 9) NULL,
  viaje_ID VARCHAR(36) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_Rutas_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  descripcion VARCHAR(255) NULL,
  distanciaKm DECIMAL(10, 2) NULL,
  latitud DECIMAL(9, 6) NULL,
  longitud DECIMAL(9, 6) NULL,
  destinosCount INTEGER NULL,
  destinosDescripcion VARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_PuntoCoordenadas_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  latitud DECIMAL(9, 6) NULL,
  longitud DECIMAL(9, 6) NULL,
  descripcion VARCHAR(255) NULL,
  ruta_ID VARCHAR(36) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_Proveedores_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  nombre VARCHAR(255) NULL,
  telefono VARCHAR(255) NULL,
  capacidad_despacho DECIMAL(10, 2) NULL,
  direccion VARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_PreciosHistoricos_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  proveedor_ID VARCHAR(36) NULL,
  precioCombustible DECIMAL(10, 2) NULL,
  precio DECIMAL(10, 2) NULL,
  litros_distribuidos DECIMAL(10, 2) NULL,
  fecha DATE NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_Rubros_drafts (
  ID VARCHAR(36) NOT NULL,
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  name VARCHAR(50) NULL,
  description VARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_Almacenes_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  nombreSede VARCHAR(255) NULL,
  ubicacion VARCHAR(255) NULL,
  responsable VARCHAR(255) NULL,
  tipo_combustible VARCHAR(255) NULL DEFAULT 'Diesel',
  capacidadTotal DECIMAL(10, 2) NULL,
  estado VARCHAR(255) NULL,
  actual FLOAT8 NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_Tanques_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  codigo VARCHAR(255) NULL,
  almacen_ID VARCHAR(36) NULL,
  tipo_combustible VARCHAR(255) NULL DEFAULT 'Diesel',
  capacidadTotal DECIMAL(10, 2) NULL,
  nivel_minimo DECIMAL(10, 2) NULL,
  nivel_actual DECIMAL(10, 2) NULL,
  ultimaFechaRecarga DATE NULL,
  descripcion VARCHAR(255) NULL,
  estadoTanque_code VARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_OrdenesCarga_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  fechaCarga TIMESTAMP NULL,
  proveedor_ID VARCHAR(36) NULL,
  tanque_ID VARCHAR(36) NULL,
  placaCamionCisterna VARCHAR(255) NULL,
  nombreChoferCisterna VARCHAR(255) NULL,
  cedulaChoferCisterna VARCHAR(255) NULL,
  carga_real DECIMAL(10, 2) NULL,
  placa_vehiculo VARCHAR(255) NULL,
  cedula_chofer VARCHAR(255) NULL,
  carga_facturada DECIMAL(10, 2) NULL,
  observacion VARCHAR(255) NULL,
  variacion DECIMAL(10, 2) NULL,
  porcentaje_conciliacion DECIMAL(5, 2) NULL,
  isFirst BOOLEAN NULL,
  almacen_ID VARCHAR(36) NULL,
  precio FLOAT8 NULL,
  choferNombreCompleto VARCHAR(255) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_TankXOrden_drafts (
  ID VARCHAR(36) NOT NULL,
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  orden_ID VARCHAR(36) NULL,
  tanque_ID VARCHAR(36) NULL,
  quantity DECIMAL(10, 2) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE TABLE ConfigService_SurtidosUnidad_drafts (
  createdAt TIMESTAMP NULL,
  createdBy VARCHAR(255) NULL,
  modifiedAt TIMESTAMP NULL,
  modifiedBy VARCHAR(255) NULL,
  ID VARCHAR(36) NOT NULL,
  fechaCarga TIMESTAMP NULL,
  vehiculo_ID VARCHAR(36) NULL,
  tanque_ID VARCHAR(36) NULL,
  carga_real DECIMAL(10, 2) NULL,
  volumenPrevioVehiculo DECIMAL(10, 2) NULL,
  volumen_actual_vehiculo DECIMAL(10, 2) NULL,
  responsable VARCHAR(255) NULL,
  cargaExterna BOOLEAN NULL DEFAULT FALSE,
  nombreEstacionServicio VARCHAR(255) NULL,
  precioCombustible DECIMAL(10, 2) NULL,
  almacen_ID VARCHAR(36) NULL,
  proveedor_ID VARCHAR(36) NULL,
  ordenCarga_ID VARCHAR(36) NULL,
  IsActiveEntity BOOLEAN,
  HasActiveEntity BOOLEAN,
  HasDraftEntity BOOLEAN,
  DraftAdministrativeData_DraftUUID VARCHAR(36) NOT NULL,
  PRIMARY KEY(ID)
);
CREATE VIEW ConfigService_Choferes AS SELECT
  Chofer_0.createdAt,
  Chofer_0.createdBy,
  Chofer_0.modifiedAt,
  Chofer_0.modifiedBy,
  Chofer_0.ID,
  Chofer_0.nombre,
  Chofer_0.apellido,
  Chofer_0.cedula,
  Chofer_0.direccion,
  Chofer_0.telefono,
  Chofer_0.rendimiento_code,
  Chofer_0.choferImage,
  Chofer_0.vehiculo_ID,
  Chofer_0.nombre || ' ' || Chofer_0.apellido AS nombreCompleto
FROM gas_app_Chofer AS Chofer_0;
CREATE VIEW ConfigService_Rendimiento AS SELECT
  Rendimiento_0.code,
  Rendimiento_0.name,
  Rendimiento_0.descr,
  Rendimiento_0.criticality,
  Rendimiento_0.qualifier
FROM gas_app_Rendimiento AS Rendimiento_0;
CREATE VIEW ConfigService_Vehiculos AS SELECT
  DbVehiculo_0.createdAt,
  DbVehiculo_0.createdBy,
  DbVehiculo_0.modifiedAt,
  DbVehiculo_0.modifiedBy,
  DbVehiculo_0.ID,
  DbVehiculo_0.placa,
  DbVehiculo_0.modelo,
  DbVehiculo_0.numeroTanques,
  DbVehiculo_0.capacidadTanque1,
  DbVehiculo_0.configuraciondelremolque,
  DbVehiculo_0.imageVehiculo,
  DbVehiculo_0.tipo_combustible,
  DbVehiculo_0.motor_ID,
  DbVehiculo_0.nivelActualCombustible,
  DbVehiculo_0.capacidadTanque2,
  DbVehiculo_0.capacidadTotal,
  DbVehiculo_0.rendimientoBase,
  DbVehiculo_0.rendimientoReal,
  DbVehiculo_0.cargautil,
  DbVehiculo_0.estadodelvehiculo_code,
  DbVehiculo_0.ejescamion_code,
  DbVehiculo_0.caja_ID,
  DbVehiculo_0.transmision_ID,
  DbVehiculo_0.chofer_ID,
  DbVehiculo_0.measure_code,
  (SELECT
      sum(ruta_4.distanciaKm)
    FROM (gas_app_Viaje AS Viaje_1 LEFT JOIN gas_app_Ruta AS ruta_4 ON Viaje_1.ruta_ID = ruta_4.ID)
    WHERE Viaje_1.vehiculo_ID = DbVehiculo_0.ID) AS kmTotales,
  (SELECT
      sum(Viaje_2.consumoRealTotal)
    FROM gas_app_Viaje AS Viaje_2
    WHERE Viaje_2.vehiculo_ID = DbVehiculo_0.ID) AS litrosTotales,
  (SELECT
      round(sum(ruta_5.distanciaKm) / sum(Viaje_3.consumoRealTotal), 2)
    FROM (gas_app_Viaje AS Viaje_3 LEFT JOIN gas_app_Ruta AS ruta_5 ON Viaje_3.ruta_ID = ruta_5.ID)
    WHERE Viaje_3.vehiculo_ID = DbVehiculo_0.ID) AS promedioKm
FROM gas_app_Vehiculo AS DbVehiculo_0;
CREATE VIEW ConfigService_Motores AS SELECT
  DbMotor_0.createdAt,
  DbMotor_0.createdBy,
  DbMotor_0.modifiedAt,
  DbMotor_0.modifiedBy,
  DbMotor_0.ID,
  DbMotor_0.modelo_code,
  DbMotor_0.serie,
  DbMotor_0.factorEficiencia,
  DbMotor_0.torqueMax,
  DbMotor_0.cilindrada,
  DbMotor_0.tipoEmision_code,
  DbMotor_0.estado_code
FROM gas_app_Motor AS DbMotor_0;
CREATE VIEW ConfigService_ModeloMotor AS SELECT
  ModeloMotor_0.code,
  ModeloMotor_0.name,
  ModeloMotor_0.descr
FROM gas_common_ModeloMotor AS ModeloMotor_0;
CREATE VIEW ConfigService_TipoEmisiones AS SELECT
  TipoEmisiones_0.code,
  TipoEmisiones_0.name,
  TipoEmisiones_0.descr,
  TipoEmisiones_0.requiereUrea,
  TipoEmisiones_0.requiereAceiteSintetico,
  TipoEmisiones_0.sensibilidadGasoil
FROM gas_common_TipoEmisiones AS TipoEmisiones_0;
CREATE VIEW ConfigService_TanqueEstados AS SELECT
  TanqueEstado_0.code,
  TanqueEstado_0.name,
  TanqueEstado_0.descr,
  TanqueEstado_0.criticality
FROM gas_common_VH_State AS TanqueEstado_0;
CREATE VIEW ConfigService_EjesCamiones AS SELECT
  EjesCamion_0.code,
  EjesCamion_0.name,
  EjesCamion_0.descr
FROM gas_common_EjesCamion AS EjesCamion_0;
CREATE VIEW ConfigService_NumeroTanquesVH AS SELECT
  DbNumeroTanques_0.code,
  DbNumeroTanques_0.name,
  DbNumeroTanques_0.descr
FROM gas_common_NumeroTanques AS DbNumeroTanques_0;
CREATE VIEW ConfigService_Cajas AS SELECT
  DbCaja_0.createdAt,
  DbCaja_0.createdBy,
  DbCaja_0.modifiedAt,
  DbCaja_0.modifiedBy,
  DbCaja_0.ID,
  DbCaja_0.modeloCaja,
  DbCaja_0.numeroVelocidades,
  DbCaja_0.factorTransmision,
  DbCaja_0.estado_code
FROM gas_app_Caja AS DbCaja_0;
CREATE VIEW ConfigService_Transmisiones AS SELECT
  DbTransmision_0.createdAt,
  DbTransmision_0.createdBy,
  DbTransmision_0.modifiedAt,
  DbTransmision_0.modifiedBy,
  DbTransmision_0.ID,
  DbTransmision_0.modeloDiferencial,
  DbTransmision_0.relacionTransmision,
  DbTransmision_0.factorTransmision,
  DbTransmision_0.tipoEje,
  DbTransmision_0.capacidadCargaEje,
  DbTransmision_0.estado_code
FROM gas_app_Transmision AS DbTransmision_0;
CREATE VIEW ConfigService_Viajes AS SELECT
  DbViaje_0.createdAt,
  DbViaje_0.createdBy,
  DbViaje_0.modifiedAt,
  DbViaje_0.modifiedBy,
  DbViaje_0.ID,
  DbViaje_0.vehiculo_ID,
  DbViaje_0.chofer_ID,
  DbViaje_0.ruta_ID,
  DbViaje_0.fecha,
  DbViaje_0.horaSalida,
  DbViaje_0.horaLlegada,
  DbViaje_0.horaLlegadaReal,
  DbViaje_0.kilometrosRecorridos,
  DbViaje_0.minHoraSalida,
  DbViaje_0.litrosSalida,
  DbViaje_0.pesoCarga,
  DbViaje_0.consumoRealTotal,
  DbViaje_0.consumoTeoricoTotal,
  DbViaje_0.kilometrosPorLitro,
  DbViaje_0.horasPorLitro,
  DbViaje_0.estatus,
  DbViaje_0.proveedor_ID,
  DbViaje_0.rendimientoTeorico,
  DbViaje_0.combustibleTeorico,
  DbViaje_0.costoTeorico,
  DbViaje_0.rubro_ID,
  DbViaje_0.pesoIda,
  DbViaje_0.pesoVuelta,
  ruta_3.descripcion AS nombreRuta,
  chofer_2.nombre || ' ' || chofer_2.apellido AS choferNombreCompleto,
  vehiculo_1.placa AS vehiculoPlaca,
  vehiculo_1.modelo AS vehiculoModelo,
  ruta_3.distanciaKm AS distanciaRuta,
  ruta_3.latitud AS rutaLatitud,
  ruta_3.longitud AS rutaLongitud,
  0 AS viajesEnRuta,
  0 AS viajesVehiculoEnRuta,
  0 AS consumoUltimo1,
  0 AS consumoUltimo2,
  0 AS consumoUltimo3
FROM (((gas_app_Viaje AS DbViaje_0 LEFT JOIN gas_app_Vehiculo AS vehiculo_1 ON DbViaje_0.vehiculo_ID = vehiculo_1.ID) LEFT JOIN gas_app_Chofer AS chofer_2 ON DbViaje_0.chofer_ID = chofer_2.ID) LEFT JOIN gas_app_Ruta AS ruta_3 ON DbViaje_0.ruta_ID = ruta_3.ID);
CREATE VIEW ConfigService_Rutas AS SELECT
  DbRuta_0.createdAt,
  DbRuta_0.createdBy,
  DbRuta_0.modifiedAt,
  DbRuta_0.modifiedBy,
  DbRuta_0.ID,
  DbRuta_0.descripcion,
  DbRuta_0.distanciaKm,
  DbRuta_0.latitud,
  DbRuta_0.longitud,
  DbRuta_0.destinosCount,
  DbRuta_0.destinosCount || ' destinos' AS destinosDescripcion
FROM gas_app_Ruta AS DbRuta_0;
CREATE VIEW ConfigService_PuntoCoordenadas AS SELECT
  DbPuntoCoordenada_0.createdAt,
  DbPuntoCoordenada_0.createdBy,
  DbPuntoCoordenada_0.modifiedAt,
  DbPuntoCoordenada_0.modifiedBy,
  DbPuntoCoordenada_0.ID,
  DbPuntoCoordenada_0.latitud,
  DbPuntoCoordenada_0.longitud,
  DbPuntoCoordenada_0.descripcion,
  DbPuntoCoordenada_0.ruta_ID
FROM gas_app_PuntoCoordenada AS DbPuntoCoordenada_0;
CREATE VIEW ConfigService_EstadoViajes AS SELECT
  EstadoViaje_0.code,
  EstadoViaje_0.name,
  EstadoViaje_0.descr
FROM gas_common_EstadoViaje AS EstadoViaje_0;
CREATE VIEW ConfigService_Telemetrias AS SELECT
  DbTelemetria_0.ID,
  DbTelemetria_0.timestamp,
  DbTelemetria_0.nivelCombustible,
  DbTelemetria_0.velocidad,
  DbTelemetria_0.altitud,
  DbTelemetria_0.latitud,
  DbTelemetria_0.longitud,
  DbTelemetria_0.viaje_ID
FROM gas_app_Telemetria AS DbTelemetria_0;
CREATE VIEW ConfigService_Proveedores AS SELECT
  DbProveedor_0.createdAt,
  DbProveedor_0.createdBy,
  DbProveedor_0.modifiedAt,
  DbProveedor_0.modifiedBy,
  DbProveedor_0.ID,
  DbProveedor_0.nombre,
  DbProveedor_0.telefono,
  DbProveedor_0.capacidad_despacho,
  DbProveedor_0.direccion
FROM gas_app_Proveedor AS DbProveedor_0;
CREATE VIEW ConfigService_PreciosHistoricos AS SELECT
  DbPrecioHistorico_0.createdAt,
  DbPrecioHistorico_0.createdBy,
  DbPrecioHistorico_0.modifiedAt,
  DbPrecioHistorico_0.modifiedBy,
  DbPrecioHistorico_0.ID,
  DbPrecioHistorico_0.proveedor_ID,
  DbPrecioHistorico_0.precioCombustible,
  DbPrecioHistorico_0.precio,
  DbPrecioHistorico_0.litros_distribuidos,
  DbPrecioHistorico_0.fecha
FROM gas_app_PrecioHistorico AS DbPrecioHistorico_0;
CREATE VIEW ConfigService_Rubros AS SELECT
  rubro_0.ID,
  rubro_0.createdAt,
  rubro_0.createdBy,
  rubro_0.modifiedAt,
  rubro_0.modifiedBy,
  rubro_0.name,
  rubro_0.description
FROM gas_app_Rubros AS rubro_0;
CREATE VIEW ConfigService_MedicionesGaso AS SELECT
  MedicionGaso_0.code,
  MedicionGaso_0.name,
  MedicionGaso_0.descr
FROM gas_common_MedicionGaso AS MedicionGaso_0;
CREATE VIEW ConfigService_ConfiguracionCamiones AS SELECT
  ConfiguracionCamion_0.code,
  ConfiguracionCamion_0.name,
  ConfiguracionCamion_0.descr
FROM gas_common_ConfiguracionCamion AS ConfiguracionCamion_0;
CREATE VIEW ConfigService_Almacenes AS SELECT
  DbAlmacen_0.createdAt,
  DbAlmacen_0.createdBy,
  DbAlmacen_0.modifiedAt,
  DbAlmacen_0.modifiedBy,
  DbAlmacen_0.ID,
  DbAlmacen_0.nombreSede,
  DbAlmacen_0.ubicacion,
  DbAlmacen_0.responsable,
  DbAlmacen_0.tipo_combustible,
  DbAlmacen_0.capacidadTotal,
  DbAlmacen_0.estado,
  coalesce((SELECT
      sum(Tanque_1.nivel_actual)
    FROM gas_app_Tanque AS Tanque_1
    WHERE Tanque_1.almacen_ID = DbAlmacen_0.ID), 0) AS actual
FROM gas_app_Almacen AS DbAlmacen_0;
CREATE VIEW ConfigService_Tanques AS SELECT
  DbTanque_0.createdAt,
  DbTanque_0.createdBy,
  DbTanque_0.modifiedAt,
  DbTanque_0.modifiedBy,
  DbTanque_0.ID,
  DbTanque_0.codigo,
  DbTanque_0.almacen_ID,
  DbTanque_0.tipo_combustible,
  DbTanque_0.capacidadTotal,
  DbTanque_0.nivel_minimo,
  DbTanque_0.nivel_actual,
  DbTanque_0.ultimaFechaRecarga,
  DbTanque_0.descripcion,
  DbTanque_0.estadoTanque_code
FROM gas_app_Tanque AS DbTanque_0;
CREATE VIEW ConfigService_OrdenesCarga AS SELECT
  DbOrdenCarga_0.createdAt,
  DbOrdenCarga_0.createdBy,
  DbOrdenCarga_0.modifiedAt,
  DbOrdenCarga_0.modifiedBy,
  DbOrdenCarga_0.ID,
  DbOrdenCarga_0.fechaCarga,
  DbOrdenCarga_0.proveedor_ID,
  DbOrdenCarga_0.tanque_ID,
  DbOrdenCarga_0.placaCamionCisterna,
  DbOrdenCarga_0.nombreChoferCisterna,
  DbOrdenCarga_0.cedulaChoferCisterna,
  DbOrdenCarga_0.carga_real,
  DbOrdenCarga_0.placa_vehiculo,
  DbOrdenCarga_0.cedula_chofer,
  DbOrdenCarga_0.carga_facturada,
  DbOrdenCarga_0.observacion,
  DbOrdenCarga_0.variacion,
  DbOrdenCarga_0.porcentaje_conciliacion,
  DbOrdenCarga_0.isFirst,
  DbOrdenCarga_0.almacen_ID,
  DbOrdenCarga_0.precio,
  chofer_1.nombre || ' ' || chofer_1.apellido AS choferNombreCompleto
FROM (gas_app_OrdenCarga AS DbOrdenCarga_0 LEFT JOIN gas_app_Chofer AS chofer_1 ON chofer_1.cedula = DbOrdenCarga_0.cedula_chofer);
CREATE VIEW ConfigService_TankXOrden AS SELECT
  TankXOrden_0.ID,
  TankXOrden_0.createdAt,
  TankXOrden_0.createdBy,
  TankXOrden_0.modifiedAt,
  TankXOrden_0.modifiedBy,
  TankXOrden_0.orden_ID,
  TankXOrden_0.tanque_ID,
  TankXOrden_0.quantity
FROM gas_app_TankXOrden AS TankXOrden_0;
CREATE VIEW ConfigService_SurtidosUnidad AS SELECT
  DbSurtidoUnidad_0.createdAt,
  DbSurtidoUnidad_0.createdBy,
  DbSurtidoUnidad_0.modifiedAt,
  DbSurtidoUnidad_0.modifiedBy,
  DbSurtidoUnidad_0.ID,
  DbSurtidoUnidad_0.fechaCarga,
  DbSurtidoUnidad_0.vehiculo_ID,
  DbSurtidoUnidad_0.tanque_ID,
  DbSurtidoUnidad_0.carga_real,
  DbSurtidoUnidad_0.volumenPrevioVehiculo,
  DbSurtidoUnidad_0.volumen_actual_vehiculo,
  DbSurtidoUnidad_0.responsable,
  DbSurtidoUnidad_0.cargaExterna,
  DbSurtidoUnidad_0.nombreEstacionServicio,
  DbSurtidoUnidad_0.precioCombustible,
  DbSurtidoUnidad_0.almacen_ID,
  DbSurtidoUnidad_0.proveedor_ID,
  DbSurtidoUnidad_0.ordenCarga_ID
FROM gas_app_SurtidoUnidad AS DbSurtidoUnidad_0;
CREATE VIEW ConfigService_TanquesDisponibles AS SELECT
  DbTanque_0.createdAt,
  DbTanque_0.createdBy,
  DbTanque_0.modifiedAt,
  DbTanque_0.modifiedBy,
  DbTanque_0.ID,
  DbTanque_0.codigo,
  DbTanque_0.almacen_ID,
  DbTanque_0.tipo_combustible,
  DbTanque_0.capacidadTotal,
  DbTanque_0.nivel_minimo,
  DbTanque_0.nivel_actual,
  DbTanque_0.ultimaFechaRecarga,
  DbTanque_0.descripcion,
  DbTanque_0.estadoTanque_code
FROM gas_app_Tanque AS DbTanque_0
WHERE DbTanque_0.nivel_actual > 0 AND DbTanque_0.estadoTanque_code = 'Operativo';
CREATE VIEW ReportingService_HechosViaje AS SELECT
  HechoViaje_0.viaje_ID,
  HechoViaje_0.vehiculo_ID,
  HechoViaje_0.chofer_ID,
  HechoViaje_0.ruta_ID,
  HechoViaje_0.motor_ID,
  HechoViaje_0.transmision_ID,
  HechoViaje_0.caja_ID,
  HechoViaje_0.proveedor_ID,
  HechoViaje_0.almacen_ID,
  HechoViaje_0.rubro_ID,
  HechoViaje_0.placaVehiculo,
  HechoViaje_0.modeloVehiculo,
  HechoViaje_0.nombreChofer,
  HechoViaje_0.cedulaChofer,
  HechoViaje_0.descripcionRuta,
  HechoViaje_0.nombreProveedor,
  HechoViaje_0.nombreAlmacen,
  HechoViaje_0.nombreRubro,
  HechoViaje_0.fechaKey,
  HechoViaje_0.fecha,
  HechoViaje_0.anio,
  HechoViaje_0.mes,
  HechoViaje_0.trimestre,
  HechoViaje_0.semanaAnio,
  HechoViaje_0.diaSemana,
  HechoViaje_0.nombreMes,
  HechoViaje_0.esFinDeSemana,
  HechoViaje_0.periodoYMD,
  HechoViaje_0.periodoYQT,
  HechoViaje_0.distanciaKm,
  HechoViaje_0.kilometrosRecorridos,
  HechoViaje_0.horasSalida,
  HechoViaje_0.horasLlegada,
  HechoViaje_0.horasLlegadaReal,
  HechoViaje_0.duracionHoras,
  HechoViaje_0.duracionTeoricaHoras,
  HechoViaje_0.litrosSalida,
  HechoViaje_0.consumoRealTotal,
  HechoViaje_0.consumoTeoricoTotal,
  HechoViaje_0.combustibleTeorico,
  HechoViaje_0.costoTeorico,
  HechoViaje_0.precioCombustible,
  HechoViaje_0.rendimientoReal,
  HechoViaje_0.rendimientoTeorico,
  HechoViaje_0.variacionRendimientoPct,
  HechoViaje_0.kilometrosPorLitro,
  HechoViaje_0.horasPorLitro,
  HechoViaje_0.pesoCarga,
  HechoViaje_0.pesoIda,
  HechoViaje_0.pesoVuelta,
  HechoViaje_0.pesoTotal,
  HechoViaje_0.toneladasPorKm,
  HechoViaje_0.estadoViaje,
  HechoViaje_0.esFinalizado,
  HechoViaje_0.esCancelado,
  HechoViaje_0.cumpleRendimientoTeorico,
  HechoViaje_0.esSobrecarga,
  HechoViaje_0.esViajeCorto,
  HechoViaje_0.esViajeLargo,
  HechoViaje_0.eficienciaCategoria,
  HechoViaje_0.costoPorKm,
  HechoViaje_0.costoPorToneladaKm,
  HechoViaje_0.velocidadPromedio,
  HechoViaje_0.velocidadMaxima,
  HechoViaje_0.altitudPromedio,
  HechoViaje_0.registrosTelemetria,
  HechoViaje_0.variacionCriticality,
  HechoViaje_0.createdAt,
  HechoViaje_0.modifiedAt
FROM gas_reporting_HechoViaje AS HechoViaje_0;
CREATE VIEW ReportingService_HechosViajeReportes AS SELECT
  HechoViaje_0.viaje_ID,
  HechoViaje_0.vehiculo_ID,
  HechoViaje_0.chofer_ID,
  HechoViaje_0.ruta_ID,
  HechoViaje_0.motor_ID,
  HechoViaje_0.transmision_ID,
  HechoViaje_0.caja_ID,
  HechoViaje_0.proveedor_ID,
  HechoViaje_0.almacen_ID,
  HechoViaje_0.rubro_ID,
  HechoViaje_0.placaVehiculo,
  HechoViaje_0.modeloVehiculo,
  HechoViaje_0.nombreChofer,
  HechoViaje_0.cedulaChofer,
  HechoViaje_0.descripcionRuta,
  HechoViaje_0.nombreProveedor,
  HechoViaje_0.nombreAlmacen,
  HechoViaje_0.nombreRubro,
  HechoViaje_0.fechaKey,
  HechoViaje_0.fecha,
  HechoViaje_0.anio,
  HechoViaje_0.mes,
  HechoViaje_0.trimestre,
  HechoViaje_0.semanaAnio,
  HechoViaje_0.diaSemana,
  HechoViaje_0.nombreMes,
  HechoViaje_0.esFinDeSemana,
  HechoViaje_0.periodoYMD,
  HechoViaje_0.periodoYQT,
  HechoViaje_0.distanciaKm,
  HechoViaje_0.kilometrosRecorridos,
  HechoViaje_0.horasSalida,
  HechoViaje_0.horasLlegada,
  HechoViaje_0.horasLlegadaReal,
  HechoViaje_0.duracionHoras,
  HechoViaje_0.duracionTeoricaHoras,
  HechoViaje_0.litrosSalida,
  HechoViaje_0.consumoRealTotal,
  HechoViaje_0.consumoTeoricoTotal,
  HechoViaje_0.combustibleTeorico,
  HechoViaje_0.costoTeorico,
  HechoViaje_0.precioCombustible,
  HechoViaje_0.rendimientoReal,
  HechoViaje_0.rendimientoTeorico,
  HechoViaje_0.variacionRendimientoPct,
  HechoViaje_0.kilometrosPorLitro,
  HechoViaje_0.horasPorLitro,
  HechoViaje_0.pesoCarga,
  HechoViaje_0.pesoIda,
  HechoViaje_0.pesoVuelta,
  HechoViaje_0.pesoTotal,
  HechoViaje_0.toneladasPorKm,
  HechoViaje_0.estadoViaje,
  HechoViaje_0.esFinalizado,
  HechoViaje_0.esCancelado,
  HechoViaje_0.cumpleRendimientoTeorico,
  HechoViaje_0.esSobrecarga,
  HechoViaje_0.esViajeCorto,
  HechoViaje_0.esViajeLargo,
  HechoViaje_0.eficienciaCategoria,
  HechoViaje_0.costoPorKm,
  HechoViaje_0.costoPorToneladaKm,
  HechoViaje_0.velocidadPromedio,
  HechoViaje_0.velocidadMaxima,
  HechoViaje_0.altitudPromedio,
  HechoViaje_0.registrosTelemetria,
  HechoViaje_0.variacionCriticality,
  HechoViaje_0.createdAt,
  HechoViaje_0.modifiedAt
FROM gas_reporting_HechoViaje AS HechoViaje_0;
CREATE VIEW ReportingService_DimensionTiempo AS SELECT
  DimTiempo_0.dateKey,
  DimTiempo_0.fecha,
  DimTiempo_0.anio,
  DimTiempo_0.mes,
  DimTiempo_0.dia,
  DimTiempo_0.trimestre,
  DimTiempo_0.semanaAnio,
  DimTiempo_0.diaSemana,
  DimTiempo_0.nombreMes,
  DimTiempo_0.nombreDia,
  DimTiempo_0.esFinDeSemana,
  DimTiempo_0.esFeriado,
  DimTiempo_0.periodoYMD,
  DimTiempo_0.periodoYQT,
  DimTiempo_0.diasDesdeInicioAnio,
  DimTiempo_0.diasHastaFinAnio
FROM gas_reporting_DimTiempo AS DimTiempo_0;
CREATE VIEW ReportingService_DimensionVehiculo AS SELECT
  DimVehiculo_0.vehiculo_ID,
  DimVehiculo_0.placa,
  DimVehiculo_0.modelo,
  DimVehiculo_0.motorModelo,
  DimVehiculo_0.transmisionModelo,
  DimVehiculo_0.cajaModelo,
  DimVehiculo_0.ejes,
  DimVehiculo_0.configuracion,
  DimVehiculo_0.capacidadTotal,
  DimVehiculo_0.cargautil,
  DimVehiculo_0.estado,
  DimVehiculo_0.antiguedadDias,
  DimVehiculo_0.categoriaCarga
FROM gas_reporting_DimVehiculo AS DimVehiculo_0;
CREATE VIEW ReportingService_DimensionChofer AS SELECT
  DimChofer_0.chofer_ID,
  DimChofer_0.nombreCompleto,
  DimChofer_0.cedula,
  DimChofer_0.rendimientoQual,
  DimChofer_0.viajesTotales,
  DimChofer_0.experienciaMeses
FROM gas_reporting_DimChofer AS DimChofer_0;
CREATE VIEW ReportingService_DimensionRuta AS SELECT
  DimRuta_0.ruta_ID,
  DimRuta_0.descripcion,
  DimRuta_0.distanciaKm,
  DimRuta_0.destinosCount,
  DimRuta_0.latitud,
  DimRuta_0.longitud,
  DimRuta_0.puntosCount,
  DimRuta_0.categoriaDistancia,
  DimRuta_0.complejidadRuta
FROM gas_reporting_DimRuta AS DimRuta_0;
CREATE VIEW ReportingService_DimensionProveedor AS SELECT
  DimProveedor_0.proveedor_ID,
  DimProveedor_0.nombre,
  DimProveedor_0.capacidadDespacho,
  DimProveedor_0.precioPromedio
FROM gas_reporting_DimProveedor AS DimProveedor_0;
CREATE VIEW ReportingService_DimensionAlmacen AS SELECT
  DimAlmacen_0.almacen_ID,
  DimAlmacen_0.nombreSede,
  DimAlmacen_0.ubicacion,
  DimAlmacen_0.estado,
  DimAlmacen_0.capacidadTotal,
  DimAlmacen_0.tanquesCount
FROM gas_reporting_DimAlmacen AS DimAlmacen_0;
CREATE VIEW ReportingService_Motores AS SELECT
  Motor_0.createdAt,
  Motor_0.createdBy,
  Motor_0.modifiedAt,
  Motor_0.modifiedBy,
  Motor_0.ID,
  Motor_0.modelo_code,
  Motor_0.serie,
  Motor_0.factorEficiencia,
  Motor_0.torqueMax,
  Motor_0.cilindrada,
  Motor_0.tipoEmision_code,
  Motor_0.estado_code
FROM gas_app_Motor AS Motor_0;
CREATE VIEW ReportingService_ModeloMotor AS SELECT
  ModeloMotor_0.code,
  ModeloMotor_0.name,
  ModeloMotor_0.descr
FROM gas_common_ModeloMotor AS ModeloMotor_0;
CREATE VIEW ReportingService_TipoEmisiones AS SELECT
  TipoEmisiones_0.code,
  TipoEmisiones_0.name,
  TipoEmisiones_0.descr,
  TipoEmisiones_0.requiereUrea,
  TipoEmisiones_0.requiereAceiteSintetico,
  TipoEmisiones_0.sensibilidadGasoil
FROM gas_common_TipoEmisiones AS TipoEmisiones_0;
CREATE VIEW ReportingService_VH_State AS SELECT
  VH_State_0.code,
  VH_State_0.name,
  VH_State_0.descr,
  VH_State_0.criticality
FROM gas_common_VH_State AS VH_State_0;
CREATE VIEW ReportingService_Transmisiones AS SELECT
  Transmision_0.createdAt,
  Transmision_0.createdBy,
  Transmision_0.modifiedAt,
  Transmision_0.modifiedBy,
  Transmision_0.ID,
  Transmision_0.modeloDiferencial,
  Transmision_0.relacionTransmision,
  Transmision_0.factorTransmision,
  Transmision_0.tipoEje,
  Transmision_0.capacidadCargaEje,
  Transmision_0.estado_code
FROM gas_app_Transmision AS Transmision_0;
CREATE VIEW gas_reporting_V_PlacasVehiculo AS SELECT
  HechoViaje_0.placaVehiculo,
  count(*) AS cantidadViajes
FROM gas_reporting_HechoViaje AS HechoViaje_0
WHERE HechoViaje_0.esFinalizado = TRUE
GROUP BY HechoViaje_0.placaVehiculo;
CREATE VIEW gas_reporting_V_ModelosVehiculo AS SELECT
  HechoViaje_0.modeloVehiculo,
  count(*) AS cantidadViajes
FROM gas_reporting_HechoViaje AS HechoViaje_0
WHERE HechoViaje_0.esFinalizado = TRUE
GROUP BY HechoViaje_0.modeloVehiculo;
CREATE VIEW gas_reporting_V_NombresChofer AS SELECT
  HechoViaje_0.nombreChofer,
  count(*) AS cantidadViajes
FROM gas_reporting_HechoViaje AS HechoViaje_0
WHERE HechoViaje_0.esFinalizado = TRUE
GROUP BY HechoViaje_0.nombreChofer;
CREATE VIEW gas_reporting_V_DescripcionesRuta AS SELECT
  HechoViaje_0.descripcionRuta,
  count(*) AS cantidadViajes
FROM gas_reporting_HechoViaje AS HechoViaje_0
WHERE HechoViaje_0.esFinalizado = TRUE
GROUP BY HechoViaje_0.descripcionRuta;
CREATE VIEW gas_reporting_V_AggMensual AS SELECT
  HechoViaje_0.anio,
  HechoViaje_0.mes,
  HechoViaje_0.nombreMes,
  HechoViaje_0.periodoYMD,
  count(*) AS cantidadViajes,
  sum(HechoViaje_0.distanciaKm) AS distanciaTotalKm,
  sum(HechoViaje_0.consumoRealTotal) AS combustibleRealTotal,
  sum(HechoViaje_0.consumoTeoricoTotal) AS combustibleTeoricoTotal,
  sum(HechoViaje_0.costoTeorico) AS costoTotal,
  avg(HechoViaje_0.rendimientoReal) AS rendimientoPromedio,
  avg(HechoViaje_0.variacionRendimientoPct) AS variacionPromedioPct,
  sum(HechoViaje_0.toneladasPorKm) AS toneladasKmTotal
FROM gas_reporting_HechoViaje AS HechoViaje_0
WHERE HechoViaje_0.esFinalizado = TRUE
GROUP BY HechoViaje_0.anio, HechoViaje_0.mes, HechoViaje_0.nombreMes, HechoViaje_0.periodoYMD;
CREATE VIEW gas_reporting_V_AggPorVehiculoRuta AS SELECT
  HechoViaje_0.placaVehiculo,
  HechoViaje_0.descripcionRuta,
  count(*) AS cantidadViajes,
  sum(HechoViaje_0.distanciaKm) AS distanciaTotalKm,
  avg(HechoViaje_0.rendimientoReal) AS rendimientoPromedio,
  avg(HechoViaje_0.variacionRendimientoPct) AS variacionPromedio,
  sum(HechoViaje_0.costoTeorico) AS costoTotal
FROM gas_reporting_HechoViaje AS HechoViaje_0
WHERE HechoViaje_0.esFinalizado = TRUE
GROUP BY HechoViaje_0.placaVehiculo, HechoViaje_0.descripcionRuta;
CREATE VIEW gas_reporting_V_AggPorChofer AS SELECT
  HechoViaje_0.nombreChofer,
  HechoViaje_0.cedulaChofer,
  count(*) AS cantidadViajes,
  sum(HechoViaje_0.distanciaKm) AS distanciaTotalKm,
  avg(HechoViaje_0.rendimientoReal) AS rendimientoPromedio,
  avg(HechoViaje_0.variacionRendimientoPct) AS variacionPromedio,
  sum(HechoViaje_0.costoTeorico) AS costoTotal,
  sum(CASE WHEN HechoViaje_0.cumpleRendimientoTeorico THEN 1 ELSE 0 END) AS viajesExitosos,
  (100.0 * sum(CASE WHEN HechoViaje_0.cumpleRendimientoTeorico THEN 1 ELSE 0 END)) / count(*) AS tasaExitoPct
FROM gas_reporting_HechoViaje AS HechoViaje_0
WHERE HechoViaje_0.esFinalizado = TRUE
GROUP BY HechoViaje_0.nombreChofer, HechoViaje_0.cedulaChofer;
CREATE VIEW gas_reporting_V_AggPorComponente AS SELECT
  HechoViaje_0.motor_ID,
  HechoViaje_0.transmision_ID,
  HechoViaje_0.caja_ID,
  HechoViaje_0.placaVehiculo,
  count(*) AS cantidadViajes,
  avg(HechoViaje_0.rendimientoReal) AS rendimientoPromedio,
  avg(HechoViaje_0.pesoTotal) AS pesoPromedio,
  avg(HechoViaje_0.costoPorKm) AS costoPromedioPorKm
FROM gas_reporting_HechoViaje AS HechoViaje_0
WHERE HechoViaje_0.esFinalizado = TRUE
GROUP BY HechoViaje_0.motor_ID, HechoViaje_0.transmision_ID, HechoViaje_0.caja_ID, HechoViaje_0.placaVehiculo;
CREATE VIEW ConfigService_DraftAdministrativeData AS SELECT
  DraftAdministrativeData.DraftUUID,
  DraftAdministrativeData.CreationDateTime,
  DraftAdministrativeData.CreatedByUser,
  DraftAdministrativeData.CreatedByUserDescription,
  DraftAdministrativeData.DraftIsCreatedByMe,
  DraftAdministrativeData.LastChangeDateTime,
  DraftAdministrativeData.LastChangedByUser,
  DraftAdministrativeData.LastChangedByUserDescription,
  DraftAdministrativeData.InProcessByUser,
  DraftAdministrativeData.InProcessByUserDescription,
  DraftAdministrativeData.DraftIsProcessedByMe,
  DraftAdministrativeData.DraftMessages
FROM DRAFT_DraftAdministrativeData AS DraftAdministrativeData;
CREATE VIEW ConfigService_PerformacePerVehicle AS SELECT
  Vehiculos_0.ID,
  Vehiculos_0.placa,
  Vehiculos_0.modelo,
  Vehiculos_0.promedioKm
FROM ConfigService_Vehiculos AS Vehiculos_0
WHERE Vehiculos_0.promedioKm IS NOT NULL;
CREATE VIEW ConfigService_PerformanceAvg AS SELECT
  avg(Viajes_0.kilometrosPorLitro) AS rendimientoPromedioGeneral,
  count(Viajes_0.ID) AS totalViajes
FROM ConfigService_Viajes AS Viajes_0;
CREATE VIEW ConfigService_PerformanceByModel AS SELECT
  Vehiculos_0.modelo,
  avg(Vehiculos_0.promedioKm) AS rendimientoPromedio
FROM ConfigService_Vehiculos AS Vehiculos_0
WHERE Vehiculos_0.promedioKm IS NOT NULL
GROUP BY Vehiculos_0.modelo;
CREATE VIEW ConfigService_TankCapacity AS SELECT
  Tanques_0.ID,
  Tanques_0.estadoTanque_code AS estado,
  Tanques_0.codigo,
  Tanques_0.descripcion || ' - ' || almacen_1.nombreSede AS descripcion,
  Tanques_0.nivel_actual || ' / ' || Tanques_0.capacidadTotal || ' L' AS nivelActual,
  Tanques_0.nivel_minimo,
  Tanques_0.capacidadTotal - Tanques_0.nivel_actual AS capacidadDisponible,
  CASE WHEN Tanques_0.capacidadTotal = 0 THEN 0 ELSE round((Tanques_0.nivel_actual * 100.0) / Tanques_0.capacidadTotal, 2) END AS porcentajeLlenado,
  CASE WHEN (CASE WHEN Tanques_0.capacidadTotal = 0 THEN 0 ELSE round((Tanques_0.nivel_actual * 100.0) / Tanques_0.capacidadTotal, 2) END) <= 25 THEN 1 WHEN (CASE WHEN Tanques_0.capacidadTotal = 0 THEN 0 ELSE round((Tanques_0.nivel_actual * 100.0) / Tanques_0.capacidadTotal, 2) END) > 25 AND (CASE WHEN Tanques_0.capacidadTotal = 0 THEN 0 ELSE round((Tanques_0.nivel_actual * 100.0) / Tanques_0.capacidadTotal, 2) END) <= 50 THEN 2 ELSE 3 END AS criticality
FROM (ConfigService_Tanques AS Tanques_0 LEFT JOIN ConfigService_Almacenes AS almacen_1 ON Tanques_0.almacen_ID = almacen_1.ID)
WHERE Tanques_0.estadoTanque_code = 'Operativo';
CREATE VIEW ConfigService_PerformancePerRoute AS SELECT
  avg(Viajes_0.kilometrosPorLitro) AS rendimientoPromedio,
  ruta_1.descripcion AS ruta
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN ConfigService_Rutas AS ruta_1 ON Viajes_0.ruta_ID = ruta_1.ID)
GROUP BY ruta_1.descripcion;
CREATE VIEW ConfigService_PerformancePerWeight AS SELECT
  avg(Viajes_0.kilometrosPorLitro) AS rendimientoPromedio,
  CASE WHEN Viajes_0.pesoCarga >= 0 AND Viajes_0.pesoCarga <= 10000 THEN '0-10000 kg' WHEN Viajes_0.pesoCarga >= 10000 AND Viajes_0.pesoCarga <= 20000 THEN '10000-20000 kg' WHEN Viajes_0.pesoCarga >= 20000 AND Viajes_0.pesoCarga <= 30000 THEN '20000-30000 kg' ELSE '30000+ kg' END AS rangoPeso
FROM ConfigService_Viajes AS Viajes_0
GROUP BY CASE WHEN Viajes_0.pesoCarga >= 0 AND Viajes_0.pesoCarga <= 10000 THEN '0-10000 kg' WHEN Viajes_0.pesoCarga >= 10000 AND Viajes_0.pesoCarga <= 20000 THEN '10000-20000 kg' WHEN Viajes_0.pesoCarga >= 20000 AND Viajes_0.pesoCarga <= 30000 THEN '20000-30000 kg' ELSE '30000+ kg' END
ORDER BY rendimientoPromedio DESC;
CREATE VIEW ConfigService_VehiclePerStatus AS SELECT
  Vehiculos_0.estadodelvehiculo_code AS estado,
  count(Vehiculos_0.ID) AS cantidad
FROM ConfigService_Vehiculos AS Vehiculos_0
GROUP BY Vehiculos_0.estadodelvehiculo_code
ORDER BY cantidad DESC;
CREATE VIEW ConfigService_TankPerStatus AS SELECT
  Tanques_0.estadoTanque_code AS status,
  count(Tanques_0.ID) AS cantidad
FROM ConfigService_Tanques AS Tanques_0
GROUP BY Tanques_0.estadoTanque_code
ORDER BY cantidad DESC;
CREATE VIEW ConfigService_UltimoPrecioCombustibleProveedor AS SELECT
  Proveedores_0.ID,
  Proveedores_0.nombre,
  (SELECT
      ph_1.precioCombustible
    FROM ConfigService_PreciosHistoricos AS ph_1
    WHERE ph_1.proveedor_ID = Proveedores_0.ID
    ORDER BY ph_1.fecha DESC
    LIMIT 1) AS ultimoPrecio
FROM ConfigService_Proveedores AS Proveedores_0;
CREATE VIEW ConfigService_TankCritical AS SELECT
  count(Tanques_0.ID) AS cantidad
FROM ConfigService_Tanques AS Tanques_0
WHERE Tanques_0.estadoTanque_code = 'Operativo' AND round((Tanques_0.nivel_actual * 100.0) / Tanques_0.capacidadTotal, 2) <= 25;
CREATE VIEW ConfigService_PerformancePlannedVSReal AS SELECT
  'ABC' AS id,
  avg(Viajes_0.kilometrosPorLitro) AS rendimientoPromedioReal,
  avg(vehiculo_1.rendimientoBase) AS rendimientoPromedioTeorico,
  CASE WHEN avg(vehiculo_1.rendimientoBase) = 0 OR avg(vehiculo_1.rendimientoBase) IS NULL THEN 0 ELSE round(((avg(Viajes_0.kilometrosPorLitro) - avg(vehiculo_1.rendimientoBase)) / avg(vehiculo_1.rendimientoBase)) * 100, 2) END AS variacionPorcentual
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN ConfigService_Vehiculos AS vehiculo_1 ON Viajes_0.vehiculo_ID = vehiculo_1.ID);
CREATE VIEW ConfigService_DriverPerformance AS SELECT
  Viajes_0.chofer_ID AS chofer_ID,
  avg(Viajes_0.kilometrosPorLitro) AS rendimientoPromedio
FROM ConfigService_Viajes AS Viajes_0
GROUP BY Viajes_0.chofer_ID;
CREATE VIEW ConfigService_PerformacePerMotor AS SELECT
  CASE WHEN motor_1.modelo_code IS NULL THEN 'No especificado' ELSE modelo_2.name END AS modeloMotor,
  avg(Vehiculos_0.promedioKm) AS rendimiento,
  max(Vehiculos_0.promedioKm) AS rendimientoMaximo
FROM ((ConfigService_Vehiculos AS Vehiculos_0 LEFT JOIN ConfigService_Motores AS motor_1 ON Vehiculos_0.motor_ID = motor_1.ID) LEFT JOIN ConfigService_ModeloMotor AS modelo_2 ON motor_1.modelo_code = modelo_2.code)
GROUP BY CASE WHEN motor_1.modelo_code IS NULL THEN 'No especificado' ELSE modelo_2.name END;
CREATE VIEW ConfigService_PerformacePerTransmision AS SELECT
  CASE WHEN transmision_1.modeloDiferencial IS NULL THEN 'No especificado' ELSE transmision_1.modeloDiferencial END AS modeloDiferencial,
  avg(Vehiculos_0.promedioKm) AS rendimiento,
  max(Vehiculos_0.promedioKm) AS rendimientoMaximo
FROM (ConfigService_Vehiculos AS Vehiculos_0 LEFT JOIN ConfigService_Transmisiones AS transmision_1 ON Vehiculos_0.transmision_ID = transmision_1.ID)
GROUP BY CASE WHEN transmision_1.modeloDiferencial IS NULL THEN 'No especificado' ELSE transmision_1.modeloDiferencial END;
CREATE VIEW ConfigService_PerformacePerCaja AS SELECT
  CASE WHEN caja_1.modeloCaja IS NULL THEN 'No especificado' ELSE caja_1.modeloCaja END AS modeloCaja,
  avg(Vehiculos_0.promedioKm) AS rendimiento,
  max(Vehiculos_0.promedioKm) AS rendimientoMaximo
FROM (ConfigService_Vehiculos AS Vehiculos_0 LEFT JOIN ConfigService_Cajas AS caja_1 ON Vehiculos_0.caja_ID = caja_1.ID)
GROUP BY CASE WHEN caja_1.modeloCaja IS NULL THEN 'No especificado' ELSE caja_1.modeloCaja END;
CREATE VIEW ConfigService_PerformancePerRubro AS SELECT
  CASE WHEN rubro_1.name IS NULL THEN 'No especificado' ELSE rubro_1.name END AS rubro,
  count(Viajes_0.ID) AS cantidad,
  avg(Viajes_0.kilometrosPorLitro) AS rendimiento,
  max(Viajes_0.kilometrosPorLitro) AS rendimientoMaximo
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN ConfigService_Rubros AS rubro_1 ON Viajes_0.rubro_ID = rubro_1.ID)
GROUP BY CASE WHEN rubro_1.name IS NULL THEN 'No especificado' ELSE rubro_1.name END;
CREATE VIEW ConfigService_ViajesPorRutaSum AS SELECT
  ruta_1.descripcion AS ruta,
  'Viajes' AS unitViajes,
  'km' AS unitKm,
  count(Viajes_0.ID) AS cantidadViajes,
  sum(ruta_1.distanciaKm) AS distanciaRecorrida
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN ConfigService_Rutas AS ruta_1 ON Viajes_0.ruta_ID = ruta_1.ID)
GROUP BY ruta_1.descripcion;
CREATE VIEW ConfigService_ViajesPorRutaTiempo AS SELECT
  ruta_1.descripcion AS ruta,
  count(Viajes_0.ID) AS cantidadViajes,
  sum(ruta_1.distanciaKm) AS distanciaRecorrida,
  SUBSTR(Viajes_0.fecha, 1, 4) AS anio,
  SUBSTR(Viajes_0.fecha, 6, 2) AS mes2
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN ConfigService_Rutas AS ruta_1 ON Viajes_0.ruta_ID = ruta_1.ID);
CREATE VIEW ConfigService_ViajesPorMes AS SELECT
  count(Viajes_0.ID) AS cantidadViajes,
  sum(ruta_1.distanciaKm) AS distanciaRecorrida,
  SUBSTR(Viajes_0.fecha, 1, 4) AS anio,
  SUBSTR(Viajes_0.fecha, 6, 2) AS mes,
  CASE WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '01' THEN 'Enero' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '02' THEN 'Febrero' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '03' THEN 'Marzo' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '04' THEN 'Abril' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '05' THEN 'Mayo' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '06' THEN 'Junio' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '07' THEN 'Julio' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '08' THEN 'Agosto' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '09' THEN 'Septiembre' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '10' THEN 'Octubre' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '11' THEN 'Noviembre' ELSE 'Diciembre' END AS nombreMes,
  SUBSTR(Viajes_0.fecha, 1, 4) || ' ' || (CASE WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '01' THEN 'Enero' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '02' THEN 'Febrero' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '03' THEN 'Marzo' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '04' THEN 'Abril' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '05' THEN 'Mayo' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '06' THEN 'Junio' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '07' THEN 'Julio' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '08' THEN 'Agosto' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '09' THEN 'Septiembre' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '10' THEN 'Octubre' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '11' THEN 'Noviembre' ELSE 'Diciembre' END) AS fechaText
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN ConfigService_Rutas AS ruta_1 ON Viajes_0.ruta_ID = ruta_1.ID)
GROUP BY SUBSTR(Viajes_0.fecha, 1, 4) || ' ' || (CASE WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '01' THEN 'Enero' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '02' THEN 'Febrero' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '03' THEN 'Marzo' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '04' THEN 'Abril' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '05' THEN 'Mayo' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '06' THEN 'Junio' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '07' THEN 'Julio' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '08' THEN 'Agosto' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '09' THEN 'Septiembre' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '10' THEN 'Octubre' WHEN SUBSTR(Viajes_0.fecha, 6, 2) = '11' THEN 'Noviembre' ELSE 'Diciembre' END)
ORDER BY SUBSTR(Viajes_0.fecha, 1, 4), SUBSTR(Viajes_0.fecha, 6, 2);
CREATE VIEW ConfigService_ViajesPorAnio AS SELECT
  count(Viajes_0.ID) AS cantidadViajes,
  sum(ruta_1.distanciaKm) AS distanciaRecorrida,
  SUBSTR(Viajes_0.fecha, 1, 4) AS anio
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN ConfigService_Rutas AS ruta_1 ON Viajes_0.ruta_ID = ruta_1.ID)
GROUP BY SUBSTR(Viajes_0.fecha, 1, 4)
ORDER BY SUBSTR(Viajes_0.fecha, 1, 4);
CREATE VIEW ConfigService_ViajesPorTrimestre AS SELECT
  count(Viajes_0.ID) AS cantidadViajes,
  sum(ruta_1.distanciaKm) AS distanciaRecorrida,
  SUBSTR(Viajes_0.fecha, 1, 4) AS anio,
  CASE WHEN SUBSTR(Viajes_0.fecha, 6, 2) IN ('01', '02', '03') THEN 'Q1' WHEN SUBSTR(Viajes_0.fecha, 6, 2) IN ('04', '05', '06') THEN 'Q2' WHEN SUBSTR(Viajes_0.fecha, 6, 2) IN ('07', '08', '09') THEN 'Q3' ELSE 'Q4' END AS trimestre,
  SUBSTR(Viajes_0.fecha, 1, 4) || ' ' || (CASE WHEN SUBSTR(Viajes_0.fecha, 6, 2) IN ('01', '02', '03') THEN 'Q1' WHEN SUBSTR(Viajes_0.fecha, 6, 2) IN ('04', '05', '06') THEN 'Q2' WHEN SUBSTR(Viajes_0.fecha, 6, 2) IN ('07', '08', '09') THEN 'Q3' ELSE 'Q4' END) AS fechaText
FROM (ConfigService_Viajes AS Viajes_0 LEFT JOIN ConfigService_Rutas AS ruta_1 ON Viajes_0.ruta_ID = ruta_1.ID)
GROUP BY SUBSTR(Viajes_0.fecha, 1, 4) || ' ' || (CASE WHEN SUBSTR(Viajes_0.fecha, 6, 2) IN ('01', '02', '03') THEN 'Q1' WHEN SUBSTR(Viajes_0.fecha, 6, 2) IN ('04', '05', '06') THEN 'Q2' WHEN SUBSTR(Viajes_0.fecha, 6, 2) IN ('07', '08', '09') THEN 'Q3' ELSE 'Q4' END)
ORDER BY SUBSTR(Viajes_0.fecha, 1, 4) || ' ' || (CASE WHEN SUBSTR(Viajes_0.fecha, 6, 2) IN ('01', '02', '03') THEN 'Q1' WHEN SUBSTR(Viajes_0.fecha, 6, 2) IN ('04', '05', '06') THEN 'Q2' WHEN SUBSTR(Viajes_0.fecha, 6, 2) IN ('07', '08', '09') THEN 'Q3' ELSE 'Q4' END);
CREATE VIEW ReportingService_PlacasVehiculo AS SELECT
  V_PlacasVehiculo_0.placaVehiculo,
  V_PlacasVehiculo_0.cantidadViajes
FROM gas_reporting_V_PlacasVehiculo AS V_PlacasVehiculo_0;
CREATE VIEW ReportingService_ModelosVehiculo AS SELECT
  V_ModelosVehiculo_0.modeloVehiculo,
  V_ModelosVehiculo_0.cantidadViajes
FROM gas_reporting_V_ModelosVehiculo AS V_ModelosVehiculo_0;
CREATE VIEW ReportingService_NombresChofer AS SELECT
  V_NombresChofer_0.nombreChofer,
  V_NombresChofer_0.cantidadViajes
FROM gas_reporting_V_NombresChofer AS V_NombresChofer_0;
CREATE VIEW ReportingService_DescripcionesRuta AS SELECT
  V_DescripcionesRuta_0.descripcionRuta,
  V_DescripcionesRuta_0.cantidadViajes
FROM gas_reporting_V_DescripcionesRuta AS V_DescripcionesRuta_0;
CREATE VIEW ReportingService_AggMensual AS SELECT
  V_AggMensual_0.anio,
  V_AggMensual_0.mes,
  V_AggMensual_0.nombreMes,
  V_AggMensual_0.periodoYMD,
  V_AggMensual_0.cantidadViajes,
  V_AggMensual_0.distanciaTotalKm,
  V_AggMensual_0.combustibleRealTotal,
  V_AggMensual_0.combustibleTeoricoTotal,
  V_AggMensual_0.costoTotal,
  V_AggMensual_0.rendimientoPromedio,
  V_AggMensual_0.variacionPromedioPct,
  V_AggMensual_0.toneladasKmTotal
FROM gas_reporting_V_AggMensual AS V_AggMensual_0;
CREATE VIEW ReportingService_AggPorVehiculoRuta AS SELECT
  V_AggPorVehiculoRuta_0.placaVehiculo,
  V_AggPorVehiculoRuta_0.descripcionRuta,
  V_AggPorVehiculoRuta_0.cantidadViajes,
  V_AggPorVehiculoRuta_0.distanciaTotalKm,
  V_AggPorVehiculoRuta_0.rendimientoPromedio,
  V_AggPorVehiculoRuta_0.variacionPromedio,
  V_AggPorVehiculoRuta_0.costoTotal
FROM gas_reporting_V_AggPorVehiculoRuta AS V_AggPorVehiculoRuta_0;
CREATE VIEW ReportingService_AggPorChofer AS SELECT
  V_AggPorChofer_0.nombreChofer,
  V_AggPorChofer_0.cedulaChofer,
  V_AggPorChofer_0.cantidadViajes,
  V_AggPorChofer_0.distanciaTotalKm,
  V_AggPorChofer_0.rendimientoPromedio,
  V_AggPorChofer_0.variacionPromedio,
  V_AggPorChofer_0.costoTotal,
  V_AggPorChofer_0.viajesExitosos,
  V_AggPorChofer_0.tasaExitoPct
FROM gas_reporting_V_AggPorChofer AS V_AggPorChofer_0;
CREATE VIEW ReportingService_AggPorComponente AS SELECT
  V_AggPorComponente_0.motor_ID,
  V_AggPorComponente_0.transmision_ID,
  V_AggPorComponente_0.caja_ID,
  V_AggPorComponente_0.placaVehiculo,
  V_AggPorComponente_0.cantidadViajes,
  V_AggPorComponente_0.rendimientoPromedio,
  V_AggPorComponente_0.pesoPromedio,
  V_AggPorComponente_0.costoPromedioPorKm
FROM gas_reporting_V_AggPorComponente AS V_AggPorComponente_0;
CREATE VIEW ConfigService_CostoCombustiblePromedio AS SELECT
  'ABC' AS id,
  sum(Viajes_0.consumoRealTotal) AS totalCombustibleConsumido,
  sum(Viajes_0.kilometrosRecorridos) AS totalKilometrosRecorridos,
  (SELECT
      avg(UltimoPrecioCombustibleProveedor_1.ultimoPrecio)
    FROM ConfigService_UltimoPrecioCombustibleProveedor AS UltimoPrecioCombustibleProveedor_1) AS precioPromedioCombustible,
  sum(Viajes_0.consumoRealTotal) * (SELECT
      avg(UltimoPrecioCombustibleProveedor_1.ultimoPrecio)
    FROM ConfigService_UltimoPrecioCombustibleProveedor AS UltimoPrecioCombustibleProveedor_1) AS costoCombustible,
  (sum(Viajes_0.consumoRealTotal) * (SELECT
      avg(UltimoPrecioCombustibleProveedor_1.ultimoPrecio)
    FROM ConfigService_UltimoPrecioCombustibleProveedor AS UltimoPrecioCombustibleProveedor_1)) / sum(Viajes_0.consumoRealTotal) AS costoPromedioPorLitro,
  CASE WHEN sum(Viajes_0.kilometrosRecorridos) = 0 OR sum(Viajes_0.kilometrosRecorridos) IS NULL THEN 0 ELSE round((sum(Viajes_0.consumoRealTotal) * (SELECT
      avg(UltimoPrecioCombustibleProveedor_1.ultimoPrecio)
    FROM ConfigService_UltimoPrecioCombustibleProveedor AS UltimoPrecioCombustibleProveedor_1)) / sum(Viajes_0.kilometrosRecorridos), 2) END AS costoPorKm
FROM ConfigService_Viajes AS Viajes_0;
CREATE VIEW ConfigService_DriverRating AS SELECT
  'ABC' AS id,
  avg(DriverPerformance_0.rendimientoPromedio) AS rendimientoPromedioConductores,
  CASE WHEN avg(DriverPerformance_0.rendimientoPromedio) IS NULL THEN 0 WHEN avg(DriverPerformance_0.rendimientoPromedio) * 25 > 100 THEN 100 ELSE round(avg(DriverPerformance_0.rendimientoPromedio) * 25, 2) END AS calificacionPromedioConductores
FROM ConfigService_DriverPerformance AS DriverPerformance_0;
[WARNING] db\common.cds.csn:14291: Element “measure_code” has not been found (in annotate:“ConfigService.Vehiculos”/element:“measure_code”)
