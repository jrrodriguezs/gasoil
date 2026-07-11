const cds = require("@sap/cds");
const { SELECT, UPDATE, where } = require("@sap/cds/lib/ql/cds-ql");
const { calcularRendimiento } = require("../../utils/rendimientoCalculator");

module.exports = async (srv) => {
  const { Viajes, Vehiculos, Motores, Rutas, Choferes, PreciosHistoricos } = cds.entities("ConfigService");

  /* srv.before("UPDATE", Viajes.drafts, async (req) => {
    const record = await SELECT.one.from(Viajes.drafts).where({ ID: req.data.ID });
    if (!record) {
      req.error(404, "Registro no encontrado");
      return;
    }
    // intercambiar keys que esten en req.data con las del record para que se puedan usar en el calculo, 
    // si no estan en req.data se usan las del record
    const updatedRecord = Object.assign({}, record, req.data);
    const { vehiculo_ID, ruta_ID, chofer_ID, pesoCarga, proveedor_ID } = updatedRecord;
    if (!vehiculo_ID || !ruta_ID || !chofer_ID || !proveedor_ID || !pesoCarga) {
      return;
    }

    const vehiculo = await SELECT.one.from(Vehiculos).where({ ID: vehiculo_ID });
    const ruta = await SELECT.one.from(Rutas).where({ ID: ruta_ID });
    const chofer = await SELECT.one.from(Choferes).where({ ID: chofer_ID });
    const motor = vehiculo ? await SELECT.one.from(Motores).where({ ID: vehiculo.motor_ID }) : null;
    const priceFuelProvider = proveedor_ID ? await SELECT.one.from(PreciosHistoricos)
      .where({ proveedor_ID: proveedor_ID }).orderBy("fecha desc") : null;

    if (!vehiculo || !ruta || !chofer || !priceFuelProvider) {
      req.error(400, "Vehículo, Ruta o Chofer no encontrados");
      return;
    }

    const rendimientoBase = vehiculo.rendimientoBase || 1;
    const eficienciaMotor = motor?.factorEficiencia || 0.9;
    const eficienciaChofer = 0.9;
    const distanciaRuta = ruta.distanciaKm || 0 //km;
    const pesoDeCarga = pesoCarga || 0; //ton
    const precioCombustible = priceFuelProvider.precio || 24.50; // Precio por litro
  
    console.log("Datos para cálculo:", {
      rendimientoBase,
      eficienciaMotor,
      eficienciaChofer,
      distanciaRuta,
      pesoDeCarga,
      precioCombustible
    })

    const rendimientoTeorico = (rendimientoBase * eficienciaMotor * eficienciaChofer) * (1 - (pesoDeCarga * 0.012));
    const combustibleTeorico = (distanciaRuta / rendimientoTeorico);
    const costoTeorico = (combustibleTeorico * precioCombustible);

    req.data.rendimientoTeorico = Math.abs(Number(rendimientoTeorico).toFixed(2));
    req.data.combustibleTeorico = Math.abs(Number(combustibleTeorico).toFixed(2));
    req.data.costoTeorico = Math.abs(Number(costoTeorico).toFixed(2));
  }); */

  srv.before("NEW", Viajes.drafts, async (req) => {
    req.data.rendimientoTeorico = 0;
    req.data.combustibleTeorico = 0;
    req.data.costoTeorico = 0;
  });


  srv.on("changeStatus", Viajes, async (req) => {
    const { ID } = req.params[0];
    console.log("Cambiando estado del viaje: ", ID);

    await UPDATE(Viajes).set({ estatus: 'EnCurso' }).where({ ID: ID });

  });

  /* srv.before("UPDATE",Viajes.drafts, async (req) => {
    const record = await SELECT.one.from(Viajes.drafts).where({ ID: req.data.ID })
    .columns(viaje => {
      viaje.pesoIda,
      viaje.pesoVuelta,
      viaje.ruta(ruta => {ruta.distanciaKm}),
      viaje.vehiculo(vehicle => {
        vehicle.ejescamion_code,
        vehicle.transmision(transmision => {transmision('*')}),
        vehicle.motor(motor => {motor('*')});
      })
    });
    if (!record) {
      req.error(404, "Registro no encontrado");
      return;
    }
    // intercambiar keys que esten en req.data con las del record para que se puedan usar en el calculo, 
    // si no estan en req.data se usan las del record
    const updatedRecord = Object.assign({}, record, req.data);
    if (!updatedRecord.pesoIda || !updatedRecord.pesoVuelta) return;
    
    console.log(updatedRecord);
    
    let peso_total = Number(updatedRecord.pesoIda || 0) + Number(updatedRecord.pesoVuelta || 0);
    let numero_ejes = updatedRecord.vehiculo?.ejescamion_code === 'TresEjes' ? 3 : 2;
    let peso_por_eje = numero_ejes > 0 ? peso_total / numero_ejes : 0;

    let log_km = updatedRecord.ruta?.distanciaKm ? Math.log(updatedRecord.ruta.distanciaKm): 0;
    let relacion_transmision = updatedRecord.vehiculo?.transmision?.relacionTransmision;
    let coeficiente_motor = updatedRecord.vehiculo?.motor?.factorEficiencia || 0;

    console.log("datos: ", {
      peso_por_eje,
      un_tramo_bool: Boolean(updatedRecord.pesoVuelta == 0),
      ln_km: log_km,
      tres_ejes_bool: numero_ejes === 3,
      relacion_transmision: relacion_transmision,
      coeficiente_motor: coeficiente_motor
    });
    

    const rendimientoTeorico = calcularRendimiento({
      peso_por_eje,
      un_tramo_bool: Boolean(updatedRecord.pesoVuelta == 0),
      ln_km: log_km,
      tres_ejes_bool: numero_ejes === 3,
      relacion_transmision: relacion_transmision,
      coeficiente_motor: coeficiente_motor
    });
    console.log(rendimientoTeorico);
    console.log("L/KM", rendimientoTeorico/1000);
    console.log("LITROS POR VIAJE", rendimientoTeorico * updatedRecord.ruta?.distanciaKm  / 1000);
    console.log("km por litro", 1 / (rendimientoTeorico/1000));w

    req.data.rendimientoTeorico = Math.abs(1 / (rendimientoTeorico/1000)).toFixed(2);
    req.data.combustibleTeorico = Math.abs(Number(
      rendimientoTeorico * updatedRecord.ruta?.distanciaKm  / 1000
    ).toFixed(2));
    
  }) */

};
