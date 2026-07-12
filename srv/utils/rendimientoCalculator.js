/**
 * ============================================================================
 * RENDIMIENTO CALCULATOR - DOCUMENTACION DE COEFICIENTES (FIX-025)
 * ============================================================================
 * 
 * ARCHIVO: srv/utils/rendimientoCalculator.js
 * PROPOSITO: Calcular el rendimiento de combustible de vehiculos de transporte
 *            de carga pesada mediante un modelo de regresion lineal multiple.
 * 
 * ============================================================================
 * ORIGEN DE LOS COEFICIENTES
 * ============================================================================
 * Los coeficientes fueron obtenidos mediante un modelo de regresion lineal
 * multiple calibrado internamente por el equipo de TANDEM. El modelo busca
 * predecir el rendimiento de combustible en funcion de caracteristicas
 * fisicas y operativas del vehiculo y la ruta.
 * 
 * TIPO DE MODELO: Regresion Lineal Multiple (OLS - Ordinary Least Squares)
 * FORMULA GENERAL: 
 *   R = Beta0 + c1*X1 + c2*X2 + c3*X3 + c4*X4 + c5*X5 + coeficiente_motor
 * 
 * Donde:
 *   R  = Rendimiento calculado (unidad: km/L, kilometros por litro de gasoil)
 *   X1 = peso_por_eje (kg por eje)
 *   X2 = un_tramo (1 si el viaje es de un solo tramo, 0 si no)
 *   X3 = ln_km (logaritmo natural de la distancia total en km)
 *   X4 = tres_ejes (1 si el vehiculo tiene 3 ejes, 0 si no)
 *   X5 = relacion_transmision (relacion de la caja de cambios)
 *   coeficiente_motor = ajuste especifico del motor (se suma como offset)
 * 
 * ============================================================================
 * METADATA DEL MODELO
 * ============================================================================
 * FECHA DE CALIBRACION: No documentada en el origen. Requiere trazabilidad.
 * DATASET DE ENTRENAMIENTO: Datos historicos de rendimiento de flota de
 *   vehiculos de carga pesada. Tamano y rango temporal desconocidos.
 * PRECISION / R^2: No documentada. Requiere validacion estadistica.
 * UNIDAD DEL RESULTADO: km/L (kilometros por litro de combustible)
 * 
 * ============================================================================
 * INTERPRETACION DE COEFICIENTES
 * ============================================================================
 * - Beta0 (intercepto): Rendimiento base estimado cuando todas las variables
 *   independientes son cero. Representa el punto de partida del modelo.
 * - c1 (positivo): A mayor peso por eje, el rendimiento MEJORA ligeramente.
 *   Contraintuitivo; puede indicar que vehiculos mas pesados tienen motores
 *   mas eficientes o rutas mas directas.
 * - c2 (negativo): Los viajes de un solo tramo REDUCEN el rendimiento.
 *   Probablemente porque viajes largos de un solo tramo implican menos paradas
 *   y menor eficiencia de combustible por aceleraciones prolongadas.
 * - c3 (negativo): A mayor distancia (ln_km), el rendimiento DISMINUYE.
 *   El logaritmo sugiere que el efecto es marginal a distancias muy largas.
 * - c4 (positivo): Vehiculos con 3 ejes tienen MEJOR rendimiento.
 *   Posiblemente por mayor estabilidad y distribucion de carga.
 * - c5 (positivo): A mayor relacion de transmision, el rendimiento MEJORA.
 *   Relaciones mas altas permiten operar a menor RPM en velocidad crucero.
 * 
 * ============================================================================
 * ADVERTENCIAS / TODO
 * ============================================================================
 * - Los coeficientes NO tienen fecha de calibracion documentada.
 * - No se conoce el R^2 ni los intervalos de confianza de los coeficientes.
 * - El modelo NO valida rangos de entrada (out-of-bounds pueden dar resultados
 *   no realistas).
 * - Se recomienda re-entrenar el modelo periodicamente con datos frescos.
 * ============================================================================
 */

/** 
 * @typedef {Object} RendimientoDatos
 * @property {Number} peso_por_eje   - Peso total del vehiculo dividido por numero de ejes (kg/eje)
 * @property {Boolean} un_tramo_bool - true = viaje de un solo tramo (sin paradas intermedias)
 * @property {Number} ln_km          - Logaritmo natural de la distancia total del recorrido (km)
 * @property {Boolean} tres_ejes_bool - true = vehiculo con configuracion de 3 ejes
 * @property {Number} relacion_transmision - Relacion de la caja de cambios (adimensional)
 * @property {Number} coeficiente_motor - Ajuste especifico del motor (km/L, se suma como offset)
 */

/** 
 * Calcula el rendimiento de combustible estimado para un vehiculo de carga.
 * 
 * @param {RendimientoDatos} datos - Objeto con las caracteristicas del vehiculo y ruta
 * @return {Number} Rendimiento calculado en km/L (kilometros por litro)
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
    
    // Conversion de booleanos a enteros (0/1) para la regresion
    const un_tramo = un_tramo_bool ? 1 : 0;
    const tres_ejes = tres_ejes_bool ? 1 : 0;
    
    // ------------------------------------------------------------------------
    // Coeficientes del modelo de regresion lineal (ver cabecera para detalles)
    // ------------------------------------------------------------------------
    
    // Beta0: Intercepto del modelo (rendimiento base en km/L)
    // Valor estimado cuando todas las variables son cero.
    const Beta0 = 424.4919764;
    
    // c1: Coeficiente de peso por eje (kg/eje)
    // Efecto: +0.00406 km/L por cada kg/eje adicional.
    // Interpretacion: A mayor peso por eje, el rendimiento mejora marginalmente.
    const c1    = 0.004064368;
    
    // c2: Coeficiente de tramo unico (viaje sin paradas)
    // Efecto: -15.41 km/L si el viaje es de un solo tramo.
    // Interpretacion: Los viajes de un solo tramo reducen el rendimiento.
    const c2    = -15.40920943;
    
    // c3: Coeficiente de distancia logaritmica (ln_km)
    // Efecto: -22.30 km/L por cada unidad de ln(km).
    // Interpretacion: A mayor distancia, el rendimiento disminuye.
    const c3    = -22.29704349;
    
    // c4: Coeficiente de configuracion de 3 ejes
    // Efecto: +25.02 km/L si el vehiculo tiene 3 ejes.
    // Interpretacion: Los vehiculos con 3 ejes tienen mejor rendimiento.
    const c4    = 25.01971995;
    
    // c5: Coeficiente de relacion de transmision
    // Efecto: +32.42 km/L por cada unidad de relacion de transmision.
    // Interpretacion: Relaciones de transmision mas altas mejoran el rendimiento.
    const c5    = 32.41757673;

    // ------------------------------------------------------------------------
    // Aplicacion de la formula de regresion lineal multiple
    // R = Beta0 + c1*X1 + c2*X2 + c3*X3 + c4*X4 + c5*X5 + coeficiente_motor
    // ------------------------------------------------------------------------
    const result = Beta0 
                 + (c1 * peso_por_eje) 
                 + (c2 * un_tramo) 
                 + (c3 * ln_km) 
                 + (c4 * tres_ejes) 
                 + (c5 * relacion_transmision) 
                 + coeficiente_motor;
 
    return result;
}

module.exports = { calcularRendimiento };
