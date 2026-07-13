const cds = require('@sap/cds');

/**
 * Sincroniza la tabla de hechos y las dimensiones de reporting
 * a partir de los datos transaccionales de GAS-APP.
 */
async function sincronizarHechosViaje() {
  const tx = cds.transaction();

  try {
    // Entidades operacionales (usamos nombres completos para evitar problemas
    // de resolución de cds.entities en entornos de servicio)
    const OP = {
      Viaje: 'gas.app.Viaje',
      Vehiculo: 'gas.app.Vehiculo',
      Chofer: 'gas.app.Chofer',
      Ruta: 'gas.app.Ruta',
      Proveedor: 'gas.app.Proveedor',
      Rubros: 'gas.app.Rubros',
      Almacen: 'gas.app.Almacen',
      Motor: 'gas.app.Motor',
      Caja: 'gas.app.Caja',
      Transmision: 'gas.app.Transmision',
      Telemetria: 'gas.app.Telemetria'
    };

    // Entidades de reporting
    const REP = {
      HechoViaje: 'gas.reporting.HechoViaje',
      DimTiempo: 'gas.reporting.DimTiempo',
      DimVehiculo: 'gas.reporting.DimVehiculo',
      DimChofer: 'gas.reporting.DimChofer',
      DimRuta: 'gas.reporting.DimRuta',
      DimProveedor: 'gas.reporting.DimProveedor',
      DimAlmacen: 'gas.reporting.DimAlmacen'
    };

    // ── 1. Leer datos operacionales ───────────────────────────────
    const [viajes, vehiculos, choferes, rutas, proveedores, rubros, almacenes, motores, cajas, transmisiones, telemetrias] = await Promise.all([
      tx.run(SELECT.from(OP.Viaje)),
      tx.run(SELECT.from(OP.Vehiculo)),
      tx.run(SELECT.from(OP.Chofer)),
      tx.run(SELECT.from(OP.Ruta)),
      tx.run(SELECT.from(OP.Proveedor)),
      tx.run(SELECT.from(OP.Rubros)),
      tx.run(SELECT.from(OP.Almacen)),
      tx.run(SELECT.from(OP.Motor)),
      tx.run(SELECT.from(OP.Caja)),
      tx.run(SELECT.from(OP.Transmision)),
      tx.run(SELECT.from(OP.Telemetria))
    ]);

    const byId = (arr) => new Map(arr.map(x => [x.ID, x]));
    const vehiculoMap = byId(vehiculos);
    const choferMap = byId(choferes);
    const rutaMap = byId(rutas);
    const proveedorMap = byId(proveedores);
    const rubroMap = byId(rubros);
    const almacenMap = byId(almacenes);
    const motorMap = byId(motores);
    const cajaMap = byId(cajas);
    const transmisionMap = byId(transmisiones);

    const telemetriaPorViaje = new Map();
    for (const t of telemetrias) {
      const lista = telemetriaPorViaje.get(t.viaje_ID) || [];
      lista.push(t);
      telemetriaPorViaje.set(t.viaje_ID, lista);
    }

    // Enriquecer viajes con relaciones ya cargadas
    const viajesEnriquecidos = viajes.map(v => ({
      ...v,
      vehiculo: v.vehiculo_ID ? vehiculoMap.get(v.vehiculo_ID) : null,
      chofer: v.chofer_ID ? choferMap.get(v.chofer_ID) : null,
      ruta: v.ruta_ID ? rutaMap.get(v.ruta_ID) : null,
      proveedor: v.proveedor_ID ? proveedorMap.get(v.proveedor_ID) : null,
      rubro: v.rubro_ID ? rubroMap.get(v.rubro_ID) : null,
      logs: telemetriaPorViaje.get(v.ID) || []
    }));

    // ── 2. Poblar DimTiempo ───────────────────────────────────────
    const fechasUnicas = [...new Set(viajes.map(v => v.fecha).filter(Boolean))];
    const dimTiempoEntries = fechasUnicas.map(fechaStr => construirDimTiempo(fechaStr));

    // ── 3. Poblar dimensiones ─────────────────────────────────────
    const dimVehiculoEntries = vehiculos.map(vh => construirDimVehiculo(vh, { motorMap, cajaMap, transmisionMap }));
    const dimChoferEntries = choferes.map(c => construirDimChofer(c, viajesEnriquecidos));
    const dimRutaEntries = rutas.map(construirDimRuta);
    const dimProveedorEntries = proveedores.map(construirDimProveedor);
    const dimAlmacenEntries = almacenes.map(construirDimAlmacen);

    // ── 4. Transformar viajes en hechos ────────────────────────────
    const hechos = viajesEnriquecidos.map(v => construirHechoViaje(v));

    // ── 5. Limpiar e insertar (full refresh) ───────────────────────
    await tx.run(DELETE.from(REP.DimTiempo));
    await tx.run(DELETE.from(REP.DimVehiculo));
    await tx.run(DELETE.from(REP.DimChofer));
    await tx.run(DELETE.from(REP.DimRuta));
    await tx.run(DELETE.from(REP.DimProveedor));
    await tx.run(DELETE.from(REP.DimAlmacen));
    await tx.run(DELETE.from(REP.HechoViaje));

    if (dimTiempoEntries.length) await tx.run(INSERT.into(REP.DimTiempo).entries(dimTiempoEntries));
    if (dimVehiculoEntries.length) await tx.run(INSERT.into(REP.DimVehiculo).entries(dimVehiculoEntries));
    if (dimChoferEntries.length) await tx.run(INSERT.into(REP.DimChofer).entries(dimChoferEntries));
    if (dimRutaEntries.length) await tx.run(INSERT.into(REP.DimRuta).entries(dimRutaEntries));
    if (dimProveedorEntries.length) await tx.run(INSERT.into(REP.DimProveedor).entries(dimProveedorEntries));
    if (dimAlmacenEntries.length) await tx.run(INSERT.into(REP.DimAlmacen).entries(dimAlmacenEntries));
    if (hechos.length) await tx.run(INSERT.into(REP.HechoViaje).entries(hechos));

    await tx.commit();
    console.log(`[Reporting] ${hechos.length} hechos sincronizados.`);
    return { sincronizados: hechos.length };

  } catch (err) {
    await tx.rollback();
    console.error('[Reporting] Error en sincronización:', err);
    throw err;
  }
}

// ─── Helpers de DimTiempo ───────────────────────────────────────────
function construirDimTiempo(fechaStr) {
  const [y, m, d] = fechaStr.split('-').map(Number);
  const fecha = new Date(Date.UTC(y, m - 1, d));
  const diaSemana = fecha.getUTCDay() || 7; // 1=Lunes, 7=Domingo
  const nombresMes = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
  const nombresDia = ['Domingo','Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'];
  const trimestre = Math.ceil(m / 3);
  const inicioAnio = new Date(Date.UTC(y, 0, 1));
  const finAnio = new Date(Date.UTC(y, 11, 31));
  const diasDesdeInicio = Math.floor((fecha - inicioAnio) / (1000 * 60 * 60 * 24));
  const diasHastaFin = Math.floor((finAnio - fecha) / (1000 * 60 * 60 * 24));
  const semanaAnio = getISOWeek(fecha);

  return {
    dateKey: `${y}${String(m).padStart(2, '0')}${String(d).padStart(2, '0')}`,
    fecha: fechaStr,
    anio: y,
    mes: m,
    dia: d,
    trimestre,
    semanaAnio,
    diaSemana,
    nombreMes: nombresMes[m - 1],
    nombreDia: nombresDia[fecha.getUTCDay()],
    esFinDeSemana: diaSemana >= 6,
    esFeriado: false,
    periodoYMD: `${y}${String(m).padStart(2, '0')}`,
    periodoYQT: `${y}-Q${trimestre}`,
    diasDesdeInicioAnio: diasDesdeInicio,
    diasHastaFinAnio: diasHastaFin
  };
}

function getISOWeek(date) {
  const tmp = new Date(date.getTime());
  tmp.setUTCDate(tmp.getUTCDate() + 4 - (tmp.getUTCDay() || 7));
  const yearStart = new Date(Date.UTC(tmp.getUTCFullYear(), 0, 1));
  return Math.ceil((((tmp - yearStart) / 86400000) + 1) / 7);
}

// ─── Helpers de dimensiones ─────────────────────────────────────────
function construirDimVehiculo(vh, { motorMap, cajaMap, transmisionMap }) {
  const createdAt = vh.createdAt ? new Date(vh.createdAt) : null;
  const antiguedadDias = createdAt ? Math.floor((Date.now() - createdAt.getTime()) / (1000 * 60 * 60 * 24)) : null;
  const cargautil = vh.cargautil || 0;
  const motor = vh.motor_ID ? motorMap.get(vh.motor_ID) : null;
  const caja = vh.caja_ID ? cajaMap.get(vh.caja_ID) : null;
  const transmision = vh.transmision_ID ? transmisionMap.get(vh.transmision_ID) : null;

  return {
    vehiculo_ID: vh.ID,
    placa: vh.placa,
    modelo: vh.modelo,
    motorModelo: motor?.modelo_code || '',
    transmisionModelo: transmision?.modeloDiferencial || '',
    cajaModelo: caja?.modeloCaja || '',
    ejes: vh.ejescamion_code || '',
    configuracion: vh.configuraciondelremolque,
    capacidadTotal: vh.capacidadTotal,
    cargautil,
    estado: vh.estadodelvehiculo_code || '',
    antiguedadDias,
    categoriaCarga: cargautil < 10 ? 'Ligera' : cargautil < 25 ? 'Media' : 'Pesada'
  };
}

function construirDimChofer(c, viajes) {
  const viajesChofer = viajes.filter(v => v.chofer_ID === c.ID);
  const primerViaje = viajesChofer.length
    ? viajesChofer.map(v => v.createdAt).sort()[0]
    : c.createdAt;
  const experienciaMeses = primerViaje
    ? Math.floor((Date.now() - new Date(primerViaje).getTime()) / (1000 * 60 * 60 * 24 * 30))
    : 0;

  return {
    chofer_ID: c.ID,
    nombreCompleto: `${c.nombre || ''} ${c.apellido || ''}`.trim(),
    cedula: c.cedula,
    rendimientoQual: c.rendimiento_code || '',
    viajesTotales: viajesChofer.length,
    experienciaMeses
  };
}

function construirDimRuta(r) {
  const puntosCount = r.puntos?.length || 0;
  const distancia = r.distanciaKm || 0;

  return {
    ruta_ID: r.ID,
    descripcion: r.descripcion,
    distanciaKm: distancia,
    destinosCount: r.destinosCount || 0,
    latitud: r.latitud,
    longitud: r.longitud,
    puntosCount,
    categoriaDistancia: distancia < 100 ? 'Corta (<100km)' : distancia < 300 ? 'Media' : 'Larga',
    complejidadRuta: puntosCount
  };
}

function construirDimProveedor(p) {
  return {
    proveedor_ID: p.ID,
    nombre: p.nombre,
    capacidadDespacho: p.capacidad_despacho,
    precioPromedio: 0
  };
}

function construirDimAlmacen(a) {
  return {
    almacen_ID: a.ID,
    nombreSede: a.nombreSede,
    ubicacion: a.ubicacion,
    estado: a.estado || '',
    capacidadTotal: a.capacidadTotal,
    tanquesCount: 0
  };
}

// ─── Helper de HechoViaje ───────────────────────────────────────────
function construirHechoViaje(v) {
  const pesoTotal = (v.pesoIda || 0) + (v.pesoVuelta || 0);
  const rendimientoReal = v.kilometrosPorLitro || 0;
  const rendimientoTeorico = v.rendimientoTeorico || 0;
  const variacion = rendimientoTeorico > 0
    ? ((rendimientoReal - rendimientoTeorico) / rendimientoTeorico) * 100
    : 0;

  const distanciaKm = v.ruta?.distanciaKm || 0;
  const cargautilKg = (v.vehiculo?.cargautil || 0) * 1000;
  const toneladasPorKm = distanciaKm > 0 ? (pesoTotal * distanciaKm) / 1000 : 0;

  const telemetria = v.logs || [];
  const velocidades = telemetria.map(t => t.velocidad).filter(x => x != null);
  const altitudes = telemetria.map(t => t.altitud).filter(x => x != null);

  const duracionHoras = (v.horaLlegadaReal && v.horaSalida)
    ? Math.round((new Date(v.horaLlegadaReal).getTime() - new Date(v.horaSalida).getTime()) / 3600000 * 100) / 100
    : 0;

  const fecha = v.fecha;
  const dimTiempo = fecha ? construirDimTiempo(fecha) : null;

  return {
    viaje_ID: v.ID,
    vehiculo_ID: v.vehiculo_ID,
    chofer_ID: v.chofer_ID,
    ruta_ID: v.ruta_ID,
    motor_ID: v.vehiculo?.motor_ID,
    transmision_ID: v.vehiculo?.transmision_ID,
    caja_ID: v.vehiculo?.caja_ID,
    proveedor_ID: v.proveedor_ID,
    almacen_ID: null,
    rubro_ID: v.rubro_ID,

    placaVehiculo: v.vehiculo?.placa,
    modeloVehiculo: v.vehiculo?.modelo,
    nombreChofer: v.chofer ? `${v.chofer.nombre || ''} ${v.chofer.apellido || ''}`.trim() : null,
    cedulaChofer: v.chofer?.cedula,
    descripcionRuta: v.ruta?.descripcion,
    nombreProveedor: v.proveedor?.nombre,
    nombreAlmacen: null,
    nombreRubro: v.rubro?.name,

    fechaKey: dimTiempo?.dateKey,
    fecha,
    anio: dimTiempo?.anio,
    mes: dimTiempo?.mes,
    trimestre: dimTiempo?.trimestre,
    semanaAnio: dimTiempo?.semanaAnio,
    diaSemana: dimTiempo?.diaSemana,
    nombreMes: dimTiempo?.nombreMes,
    esFinDeSemana: dimTiempo?.esFinDeSemana,
    periodoYMD: dimTiempo?.periodoYMD,
    periodoYQT: dimTiempo?.periodoYQT,

    distanciaKm,
    kilometrosRecorridos: v.kilometrosRecorridos,
    horasSalida: v.horaSalida,
    horasLlegada: v.horaLlegada,
    horasLlegadaReal: v.horaLlegadaReal,
    duracionHoras,
    duracionTeoricaHoras: distanciaKm > 0 ? Math.round((distanciaKm / 60) * 100) / 100 : 0,

    litrosSalida: v.litrosSalida,
    consumoRealTotal: v.consumoRealTotal,
    consumoTeoricoTotal: v.consumoTeoricoTotal,
    combustibleTeorico: v.combustibleTeorico,
    costoTeorico: v.costoTeorico,
    precioCombustible: null,

    rendimientoReal,
    rendimientoTeorico,
    variacionRendimientoPct: Math.round(variacion * 100) / 100,
    kilometrosPorLitro: v.kilometrosPorLitro,
    horasPorLitro: v.horasPorLitro,

    pesoCarga: v.pesoCarga,
    pesoIda: v.pesoIda,
    pesoVuelta: v.pesoVuelta,
    pesoTotal,
    toneladasPorKm,

    estadoViaje: v.estatus,
    esFinalizado: v.estatus === 'Finalizado',
    esCancelado: v.estatus === 'Cancelado',
    cumpleRendimientoTeorico: variacion >= -5,
    esSobrecarga: cargautilKg > 0 && pesoTotal > cargautilKg * 0.9,
    esViajeCorto: distanciaKm < 50,
    esViajeLargo: distanciaKm > 500,
    eficienciaCategoria: variacion >= 0 ? 'Excelente' :
                          variacion >= -5 ? 'Buena' :
                          variacion >= -15 ? 'Regular' : 'Mala',
    costoPorKm: (v.costoTeorico && distanciaKm > 0) ? Math.round((v.costoTeorico / distanciaKm) * 100) / 100 : 0,
    costoPorToneladaKm: (v.costoTeorico && toneladasPorKm > 0) ? Math.round((v.costoTeorico / toneladasPorKm) * 10000) / 10000 : 0,

    velocidadPromedio: velocidades.length ? Math.round((velocidades.reduce((a, b) => a + b, 0) / velocidades.length) * 100) / 100 : 0,
    velocidadMaxima: velocidades.length ? Math.max(...velocidades) : 0,
    altitudPromedio: altitudes.length ? Math.round((altitudes.reduce((a, b) => a + b, 0) / altitudes.length) * 100) / 100 : 0,
    registrosTelemetria: telemetria.length,

    variacionCriticality: variacion >= 0 ? 3 :
                          variacion >= -5 ? 2 :
                          variacion >= -15 ? 1 : 0,

    createdAt: v.createdAt,
    modifiedAt: v.modifiedAt
  };
}

module.exports = { sincronizarHechosViaje };
