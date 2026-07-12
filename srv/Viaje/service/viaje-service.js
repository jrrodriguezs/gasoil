const cds = require("@sap/cds");
const { SELECT, UPDATE, where } = require("@sap/cds/lib/ql/cds-ql");
const { calcularRendimiento } = require("../../utils/rendimientoCalculator");

module.exports = async (srv) => {
  const { Viajes, Vehiculos, Motores, Rutas, Choferes, PreciosHistoricos } = cds.entities("ConfigService");

  srv.before("UPDATE", Viajes.drafts, async (req) => {
    // ── Validación de transiciones de estado (FIX-026) ──
    if (req.data.estatus !== undefined) {
      const viajeActual = await SELECT.one.from(Viajes.drafts)
        .where({ ID: req.data.ID })
        .columns(viaje => { viaje.estatus; });

      const estadoActual = viajeActual?.estatus;
      const estadoNuevo  = req.data.estatus;

      if (estadoActual && estadoActual !== estadoNuevo) {
        const transicionesValidas = {
          Programado: ['EnCurso', 'Finalizado', 'Cancelado'],
          EnCurso:    ['Finalizado']
        };

        const permitidos = transicionesValidas[estadoActual] || [];
        if (!permitidos.includes(estadoNuevo)) {
          req.error(400, `Transición de estado inválida: ${estadoActual} → ${estadoNuevo}`);
          return;
        }
      }
    }

    try {
      const record = await SELECT.one.from(Viajes.drafts).where({ ID: req.data.ID })
        .columns(viaje => {
          viaje.pesoIda,
          viaje.pesoVuelta,
          viaje.proveedor_ID,
          viaje.ruta(ruta => { ruta.distanciaKm }),
          viaje.vehiculo(vehicle => {
            vehicle.ejescamion_code,
            vehicle.transmision(transmision => { transmision('*') }),
            vehicle.motor(motor => { motor('*') });
          })
        });
      if (!record) {
        req.warn('No se encontró el registro del viaje para calcular rendimiento');
        return;
      }

      const updatedRecord = Object.assign({}, record, req.data);
      if (!updatedRecord.pesoIda || !updatedRecord.ruta?.distanciaKm || !updatedRecord.vehiculo?.motor) {
        req.warn('Datos insuficientes para calcular rendimiento teórico');
        return;
      }

      const peso_total = Number(updatedRecord.pesoIda || 0) + Number(updatedRecord.pesoVuelta || 0);
      const numero_ejes = updatedRecord.vehiculo?.ejescamion_code === 'TresEjes' ? 3 : 2;
      const peso_por_eje = numero_ejes > 0 ? peso_total / numero_ejes : 0;
      const log_km = updatedRecord.ruta?.distanciaKm ? Math.log(updatedRecord.ruta.distanciaKm) : 0;
      const relacion_transmision = updatedRecord.vehiculo?.transmision?.relacionTransmision || 0;
      const coeficiente_motor = updatedRecord.vehiculo?.motor?.factorEficiencia || 0;

      const rendimientoRaw = calcularRendimiento({
        peso_por_eje,
        un_tramo_bool: Boolean(!updatedRecord.pesoVuelta || updatedRecord.pesoVuelta == 0),
        ln_km: log_km,
        tres_ejes_bool: numero_ejes === 3,
        relacion_transmision: relacion_transmision,
        coeficiente_motor: coeficiente_motor
      });

      const rendimientoTeorico = rendimientoRaw > 0 ? 1 / (rendimientoRaw / 1000) : 0;
      const distanciaKm = Number(updatedRecord.ruta?.distanciaKm || 0);
      const combustibleTeorico = rendimientoTeorico > 0 && distanciaKm > 0 ? distanciaKm / rendimientoTeorico : 0;

      let precioCombustible = 0;
      if (updatedRecord.proveedor_ID) {
        const priceRecord = await SELECT.one.from(PreciosHistoricos)
          .where({ proveedor_ID: updatedRecord.proveedor_ID }).orderBy({ fecha: 'desc' });
        precioCombustible = priceRecord?.precio || 0;
      }
      const costoTeorico = combustibleTeorico * precioCombustible;

      req.data.rendimientoTeorico = parseFloat(rendimientoTeorico.toFixed(2));
      req.data.combustibleTeorico = parseFloat(combustibleTeorico.toFixed(2));
      req.data.costoTeorico = parseFloat(costoTeorico.toFixed(2));

    } catch (error) {
      console.error('Error calculando rendimiento teórico:', error);
      req.warn('No se pudo calcular el rendimiento teórico automáticamente');
    }
  });

  srv.before("NEW", Viajes.drafts, async (req) => {
    req.data.rendimientoTeorico = 0;
    req.data.combustibleTeorico = 0;
    req.data.costoTeorico = 0;
  });


  srv.on("changeStatus", Viajes, async (req) => {
    const { ID } = req.params[0];
    const estadoNuevo = req.data.estatus;

    console.log("Cambiando estado del viaje: ", ID, "→", estadoNuevo);

    const viaje = await SELECT.one.from(Viajes).where({ ID: ID }).columns(v => { v.estatus; });
    if (!viaje) {
      req.error(404, `Viaje ${ID} no encontrado`);
      return;
    }

    const estadoActual = viaje.estatus;

    const transicionesValidas = {
      Programado: ['EnCurso', 'Finalizado', 'Cancelado'],
      EnCurso:    ['Finalizado']
    };

    const permitidos = transicionesValidas[estadoActual] || [];
    if (!permitidos.includes(estadoNuevo)) {
      req.error(400, `Transición de estado inválida: ${estadoActual} → ${estadoNuevo}`);
      return;
    }

    await UPDATE(Viajes).set({ estatus: estadoNuevo }).where({ ID: ID });
  });

};
