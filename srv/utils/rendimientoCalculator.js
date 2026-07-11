/** 
 * @typedef {Object} RendimientoDatos
 * @property {Number} peso_por_eje
 * @property {Boolean} un_tramo_bool
 * @property {Number} ln_km
 * @property {Boolean} tres_ejes_bool
 * @property {Number} relacion_transmision
 * @property {Number} coeficiente_motor
 */

/** 
 * @param {RendimientoDatos} datos
 * @return {Number} rendimiento calculado
 */
function calcularRendimiento(datos={
    peso_por_eje,
    un_tramo_bool,
    ln_km,
    tres_ejes_bool,
    relacion_transmision,
    coeficiente_motor
}){
    const { peso_por_eje, un_tramo_bool, ln_km, tres_ejes_bool, relacion_transmision, coeficiente_motor } = datos;
    const un_tramo = un_tramo_bool ? 1 : 0;
    const tres_ejes = tres_ejes_bool ? 1 : 0;
    const Beta0 = 424.4919764;  //Valor base del modelo
    const c1    = 0.004064368;  //Factor para el Peso
    const c2    = -15.40920943; //(Factor para tramos con carga
    const c3    = -22.29704349; // Factor para distancia logarítmica
    const c4    = 25.01971995;  //Factor para configuración de 3 ejes
    const c5    = 32.41757673;  //Factor para relación de transmisión


    const result = Beta0 + (c1 * peso_por_eje) + (c2 * un_tramo) + (c3 * ln_km) + (c4 * tres_ejes) + (c5 * relacion_transmision) + coeficiente_motor;
 
    return result;
}

module.exports = { calcularRendimiento };