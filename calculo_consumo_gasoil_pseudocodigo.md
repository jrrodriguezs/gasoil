# Documento técnico: Cálculo del consumo de gasoil con pseudocódigo

> **Propósito:** describir paso a paso, con pseudocódigo, los cálculos de rendimiento y consumo de gasoil en la aplicación GAS-APP. Incluye la explicación del modelo de regresión lineal múltiple usado para estimar el rendimiento teórico.

---

## 1. Datos de entrada necesarios

Para calcular el consumo de gasoil se requieren datos de tres fuentes:

### 1.1 Datos del viaje

| Variable | Tipo | Unidad | Descripción |
|----------|------|--------|-------------|
| `distanciaKm` | decimal | km | Distancia de la ruta (o kilómetros recorridos reales). |
| `pesoIda` | decimal | kg | Peso transportado de ida. |
| `pesoVuelta` | decimal | kg | Peso transportado de vuelta (puede ser 0). |
| `numeroEjes` | entero | - | 2 o 3 ejes. |
| `esUnTramo` | booleano | - | `true` si el viaje solo tiene ida (sin vuelta). |
| `proveedorId` | UUID | - | Identificador del proveedor de combustible. |

### 1.2 Datos del vehículo

| Variable | Tipo | Unidad | Descripción |
|----------|------|--------|-------------|
| `relacionTransmision` | decimal | adimensional | Relación de la caja de cambios. |
| `factorEficienciaMotor` | decimal | - | Coeficiente específico del motor. |
| `numeroEjes` | entero | - | 2 o 3 (debe coincidir con el dato del viaje). |
| `rendimientoBase` | decimal | km/L | Rendimiento nominal del vehículo (referencia). |

### 1.3 Datos de telemetría y surtidos (para consumo real)

| Variable | Tipo | Unidad | Descripción |
|----------|------|--------|-------------|
| `combustibleInicial` | decimal | L | Nivel de combustible al inicio del viaje. |
| `surtidos[]` | lista | - | Lista de surtidos vinculados al viaje. Cada uno tiene `litrosCargados`. |
| `telemetrias[]` | lista | - | Registros ordenados por tiempo con `nivelCombustible`, `latitud`, `longitud`, `velocidad`. |
| `precioCombustible` | decimal | USD/L | Precio vigente al momento del viaje. |

---

## 2. Modelo de regresión lineal múltiple

### 2.1 ¿Qué es?

Una **regresión lineal múltiple** intenta predecir una variable numérica (la variable dependiente) a partir de varias variables independientes, usando una ecuación de la forma:

```text
Y = β0 + β1·X1 + β2·X2 + ... + βn·Xn + ε
```

Donde:

- `Y` es el valor que queremos predecir.
- `β0` es el intercepto (valor base cuando todas las X son 0).
- `β1 ... βn` son los coeficientes que indican cuánto cambia `Y` cuando cambia cada `Xi`.
- `Xi` son las variables independientes (entrada).
- `ε` es el error residual.

El método ajusta los coeficientes para minimizar la diferencia entre los valores predichos y los valores observados (mínimos cuadrados).

### 2.2 Variables del modelo GAS-APP

El modelo actual predice el **consumo específico de combustible** en función de características del vehículo y la ruta:

| Variable | Significado | Tipo |
|----------|-------------|------|
| `X1` | Peso por eje (`peso_por_eje`) | numérico (kg/eje) |
| `X2` | Viaje de un solo tramo (`un_tramo`) | booleano → 0 o 1 |
| `X3` | Logaritmo natural de la distancia (`ln_km`) | numérico |
| `X4` | Vehículo de tres ejes (`tres_ejes`) | booleano → 0 o 1 |
| `X5` | Relación de transmisión (`relacion_transmision`) | numérico |
| `Xm` | Coeficiente específico del motor (`coeficiente_motor`) | numérico (sumado como offset) |

### 2.3 Interpretación de los coeficientes actuales

El modelo actual tiene los siguientes coeficientes:

```text
β0 = 424.4919764       (intercepto)
β1 =   0.004064368     (peso por eje)
β2 = -15.40920943      (viaje de un tramo)
β3 = -22.29704349      (ln de la distancia)
β4 =  25.01971995      (tres ejes)
β5 =  32.41757673      (relación de transmisión)
```

> **Nota importante sobre unidades:** el valor del intercepto (~424) es demasiado alto para representar `km/L` (rendimiento). En cambio, tiene sentido como **litros consumidos por cada 1000 km**. Por tanto, el modelo predice un consumo en `L/1000km`. Para obtener el rendimiento en `km/L` se hace la inversa: `rendimiento = 1000 / consumo`.

Interpretación de cada coeficiente:

- `β0`: punto de partida. Si todas las variables fueran 0, el consumo base sería ~424 L/1000km.
- `β1` (positivo): a mayor peso por eje, el consumo aumenta ligeramente.
- `β2` (negativo): un viaje de un solo tramo reduce el consumo en ~15.4 L/1000km.
- `β3` (negativo): a mayor distancia (logaritmo), el consumo disminuye (efecto marginal).
- `β4` (positivo): los vehículos de 3 ejes consumen ~25 L/1000km más.
- `β5` (positivo): una mayor relación de transmisión aumenta el consumo en ~32.4 L/1000km por unidad.
- `coeficiente_motor`: suma un ajuste específico del motor.

### 2.4 Limitaciones del modelo

- Los coeficientes están hardcodeados y no tienen fecha de calibración documentada.
- No se conoce el R² ni los intervalos de confianza.
- No se validan rangos de entrada; valores fuera de los rangos de entrenamiento pueden dar resultados absurdos.
- No se usa el `rendimientoBase` del vehículo como referencia.

---

## 3. Pseudocódigo: cálculo del rendimiento teórico

### 3.1 Entrada

```
funcion calcularRendimientoTeorico(viaje, vehiculo, coeficientesModelo):
    entrada:
        viaje.distanciaKm
        viaje.pesoIda
        viaje.pesoVuelta
        viaje.esUnTramo
        vehiculo.numeroEjes
        vehiculo.relacionTransmision
        vehiculo.factorEficienciaMotor
        coeficientesModelo.Beta0
        coeficientesModelo.c1
        coeficientesModelo.c2
        coeficientesModelo.c3
        coeficientesModelo.c4
        coeficientesModelo.c5
```

### 3.2 Proceso

```
    // 1. Calcular peso total
    pesoTotal = viaje.pesoIda + viaje.pesoVuelta

    // 2. Calcular peso por eje
    si vehiculo.numeroEjes > 0 entonces
        pesoPorEje = pesoTotal / vehiculo.numeroEjes
    sino
        lanzar error "El vehículo debe tener al menos 1 eje"
    fin si

    // 3. Determinar si es un viaje de un solo tramo
    // Un tramo = solo ida (no hay peso de vuelta)
    si viaje.pesoVuelta == 0 o viaje.pesoVuelta es nulo entonces
        unTramo = 1
    sino
        unTramo = 0
    fin si

    // 4. Determinar configuración de ejes
    si vehiculo.numeroEjes == 3 entonces
        tresEjes = 1
    sino
        tresEjes = 0
    fin si

    // 5. Calcular logaritmo natural de la distancia
    si viaje.distanciaKm > 0 entonces
        lnKm = logaritmoNatural(viaje.distanciaKm)
    sino
        lanzar error "La distancia debe ser mayor a 0"
    fin si

    // 6. Aplicar el modelo de regresión lineal
    // Resultado: consumo en L/1000km
    consumoLpor1000km = coeficientesModelo.Beta0
                      + coeficientesModelo.c1 * pesoPorEje
                      + coeficientesModelo.c2 * unTramo
                      + coeficientesModelo.c3 * lnKm
                      + coeficientesModelo.c4 * tresEjes
                      + coeficientesModelo.c5 * vehiculo.relacionTransmision
                      + vehiculo.factorEficienciaMotor

    // 7. Validar que el consumo sea positivo y razonable
    si consumoLpor1000km <= 0 entonces
        lanzar error "El modelo arrojó un consumo no válido: " + consumoLpor1000km
    fin si

    si consumoLpor1000km > 1000 entonces
        advertir "El consumo estimado es muy alto (" + consumoLpor1000km + " L/1000km); revise los datos de entrada"
    fin si

    // 8. Convertir a rendimiento en km/L
    rendimientoKmPorLitro = 1000 / consumoLpor1000km

    // 9. Retornar resultado
    retornar {
        consumoLpor1000km: consumoLpor1000km,
        rendimientoKmPorLitro: rendimientoKmPorLitro
    }
fin funcion
```

---

## 4. Pseudocódigo: cálculo del combustible y costo teóricos

### 4.1 Entrada

```
funcion calcularCombustibleYCostoTeoricos(viaje, rendimientoKmPorLitro, precioCombustible):
    entrada:
        viaje.distanciaKm
        rendimientoKmPorLitro   // resultado de la función anterior
        precioCombustible       // USD/L
```

### 4.2 Proceso

```
    // 1. Calcular combustible teórico necesario
    si rendimientoKmPorLitro > 0 entonces
        combustibleTeoricoLitros = viaje.distanciaKm / rendimientoKmPorLitro
    sino
        combustibleTeoricoLitros = 0
    fin si

    // 2. Calcular costo teórico
    costoTeoricoUSD = combustibleTeoricoLitros * precioCombustible

    // 3. Redondear a 2 decimales
    combustibleTeoricoLitros = redondear(combustibleTeoricoLitros, 2)
    costoTeoricoUSD = redondear(costoTeoricoUSD, 2)

    // 4. Retornar resultado
    retornar {
        combustibleTeoricoLitros: combustibleTeoricoLitros,
        costoTeoricoUSD: costoTeoricoUSD
    }
fin funcion
```

---

## 5. Pseudocódigo: cálculo del consumo real

### 5.1 Entrada

```
funcion calcularConsumoReal(viaje, surtidos, telemetrias):
    entrada:
        viaje.combustibleInicial   // L
        surtidos[]                 // cada uno: litrosCargados
        telemetrias[]              // cada uno: nivelCombustible, latitud, longitud, velocidad, timestamp
```

### 5.2 Proceso

```
    // 1. Sumar todos los surtidos vinculados al viaje
    totalSurtidos = 0
    para cada surtido en surtidos hacer
        totalSurtidos = totalSurtidos + surtido.litrosCargados
    fin para

    // 2. Obtener nivel de combustible final (última telemetría válida)
    si telemetrias tiene elementos entonces
        telemetriasOrdenadas = ordenar(telemetrias, por timestamp ascendente)
        nivelFinal = ultimoElemento(telemetriasOrdenadas).nivelCombustible
    sino
        nivelFinal = viaje.combustibleInicial
    fin si

    // 3. Calcular consumo real neto
    // combustible inicial + surtidos - nivel final = litros consumidos
    consumoRealTotal = viaje.combustibleInicial + totalSurtidos - nivelFinal

    si consumoRealTotal < 0 entonces
        lanzar error "El consumo real calculado es negativo; revise telemetrías y surtidos"
    fin si

    // 4. Calcular kilómetros recorridos (Haversine, velocidad > 5 km/h)
    kilometrosRecorridos = 0
    para i desde 1 hasta longitud(telemetriasOrdenadas) - 1 hacer
        puntoAnterior = telemetriasOrdenadas[i - 1]
        puntoActual = telemetriasOrdenadas[i]

        velocidad = puntoActual.velocidad

        si velocidad > 5 entonces
            distancia = distanciaHaversine(
                puntoAnterior.latitud, puntoAnterior.longitud,
                puntoActual.latitud, puntoActual.longitud
            )
            kilometrosRecorridos = kilometrosRecorridos + distancia
        fin si
    fin para

    kilometrosRecorridos = redondear(kilometrosRecorridos, 2)

    // 5. Calcular rendimiento real
    si consumoRealTotal > 0 entonces
        rendimientoRealKmPorLitro = kilometrosRecorridos / consumoRealTotal
    sino
        rendimientoRealKmPorLitro = 0
    fin si

    // 6. Calcular costo real
    costoRealUSD = consumoRealTotal * viaje.precioCombustible

    // 7. Redondear resultados
    consumoRealTotal = redondear(consumoRealTotal, 2)
    rendimientoRealKmPorLitro = redondear(rendimientoRealKmPorLitro, 2)
    costoRealUSD = redondear(costoRealUSD, 2)

    // 8. Retornar resultado
    retornar {
        consumoRealTotal: consumoRealTotal,
        kilometrosRecorridos: kilometrosRecorridos,
        rendimientoRealKmPorLitro: rendimientoRealKmPorLitro,
        costoRealUSD: costoRealUSD
    }
fin funcion
```

### 5.3 Función auxiliar: distancia Haversine

```
funcion distanciaHaversine(lat1, lon1, lat2, lon2):
    R = 6371  // radio de la Tierra en km

    dLat = (lat2 - lat1) * PI / 180
    dLon = (lon2 - lon1) * PI / 180

    a = seno(dLat / 2)^2 +
        coseno(lat1 * PI / 180) * coseno(lat2 * PI / 180) *
        seno(dLon / 2)^2

    c = 2 * atan2(raizCuadrada(a), raizCuadrada(1 - a))

    retornar R * c
fin funcion
```

---

## 6. Pseudocódigo: desviación entre consumo real y teórico

### 6.1 Entrada

```
funcion calcularDesviacion(consumoRealTotal, combustibleTeoricoLitros):
    entrada:
        consumoRealTotal
        combustibleTeoricoLitros
```

### 6.2 Proceso

```
    // 1. Diferencia absoluta en litros
    desviacionConsumoLitros = consumoRealTotal - combustibleTeoricoLitros

    // 2. Diferencia porcentual respecto al teórico
    si combustibleTeoricoLitros > 0 entonces
        desviacionPorcentaje = (desviacionConsumoLitros / combustibleTeoricoLitros) * 100
    sino
        desviacionPorcentaje = 0
    fin si

    // 3. Redondear
    desviacionConsumoLitros = redondear(desviacionConsumoLitros, 2)
    desviacionPorcentaje = redondear(desviacionPorcentaje, 2)

    retornar {
        desviacionConsumoLitros: desviacionConsumoLitros,
        desviacionPorcentaje: desviacionPorcentaje
    }
fin funcion
```

---

## 7. Ejemplo numérico completo

### 7.1 Datos del ejemplo

```text
Viaje:
  distanciaKm = 350 km
  pesoIda = 25000 kg
  pesoVuelta = 0 kg
  esUnTramo = true

Vehículo:
  numeroEjes = 3
  relacionTransmision = 0.9
  factorEficienciaMotor = 0

Coeficientes del modelo:
  Beta0 = 424.4919764
  c1 = 0.004064368
  c2 = -15.40920943
  c3 = -22.29704349
  c4 = 25.01971995
  c5 = 32.41757673

Precio:
  precioCombustible = 1.25 USD/L

Consumo real:
  combustibleInicial = 300 L
  surtidos = [{ litrosCargados: 100 L }]
  nivelFinal = 150 L
  kilometrosRecorridos = 340 km
```

### 7.2 Paso 1: rendimiento teórico

```text
pesoTotal = 25000 + 0 = 25000 kg
pesoPorEje = 25000 / 3 = 8333.33 kg/eje
unTramo = 1 (porque pesoVuelta = 0)
tresEjes = 1
lnKm = ln(350) = 5.8579

consumoLpor1000km = 424.4919764
                  + 0.004064368 * 8333.33
                  - 15.40920943 * 1
                  - 22.29704349 * 5.8579
                  + 25.01971995 * 1
                  + 32.41757673 * 0.9
                  + 0

consumoLpor1000km ≈ 424.49 + 33.87 - 15.41 - 130.60 + 25.02 + 29.18
consumoLpor1000km ≈ 366.55 L/1000km

rendimientoKmPorLitro = 1000 / 366.55 = 2.72 km/L
```

### 7.3 Paso 2: combustible y costo teóricos

```text
combustibleTeoricoLitros = 350 km / 2.72 km/L = 128.68 L
costoTeoricoUSD = 128.68 L * 1.25 USD/L = 160.85 USD
```

### 7.4 Paso 4: consumo real

```text
consumoRealTotal = 300 + 100 - 150 = 250 L

rendimientoRealKmPorLitro = 340 km / 250 L = 1.36 km/L

costoRealUSD = 250 L * 1.25 USD/L = 312.50 USD
```

### 7.5 Paso 5: desviación

```text
desviacionConsumoLitros = 250 - 128.68 = 121.32 L
desviacionPorcentaje = (121.32 / 128.68) * 100 = 94.4%
```

> En este ejemplo, el consumo real es mucho mayor que el teórico. Esto podría deberse a datos anómalos, tráfico, condiciones climáticas, o un modelo que necesita recalibración.

---

## 8. Manejo de errores y casos borde

| Caso | Acción |
|------|--------|
| `distanciaKm <= 0` | Error: la distancia debe ser mayor a cero. |
| `numeroEjes <= 0` | Error: el vehículo debe tener ejes válidos. |
| `consumoLpor1000km <= 0` | Error: el modelo arrojó un consumo no válido. Revisar coeficientes o datos de entrada. |
| `consumoRealTotal < 0` | Error: el consumo real no puede ser negativo. Revisar surtidos o telemetrías. |
| `combustibleInicial` es nulo | Usar el `nivelActualCombustible` del vehículo al inicio del viaje. |
| `telemetrias` vacía | Consumo real no calculable; dejar en 0 o nulo y advertir. |
| `combustibleTeoricoLitros = 0` | Desviación porcentual no calculable; dejar en 0. |
| Surtido no vinculado a viaje | No se suma al consumo de ningún viaje; solo afecta inventario del vehículo. |
| Repostaje durante el viaje | Se suma a `totalSurtidos`, permitiendo calcular el consumo neto correctamente. |

---

## 9. Resumen de fórmulas

```text
pesoTotal = pesoIda + pesoVuelta
pesoPorEje = pesoTotal / numeroEjes

consumoLpor1000km = β0
                    + β1 * pesoPorEje
                    + β2 * unTramo
                    + β3 * ln(distanciaKm)
                    + β4 * tresEjes
                    + β5 * relacionTransmision
                    + factorEficienciaMotor

rendimientoKmPorLitro = 1000 / consumoLpor1000km

combustibleTeoricoLitros = distanciaKm / rendimientoKmPorLitro
costoTeoricoUSD = combustibleTeoricoLitros * precioCombustible

consumoRealTotal = combustibleInicial + suma(surtidos.litrosCargados) - nivelFinal
rendimientoRealKmPorLitro = kilometrosRecorridos / consumoRealTotal
costoRealUSD = consumoRealTotal * precioCombustible

desviacionConsumoLitros = consumoRealTotal - combustibleTeoricoLitros
desviacionPorcentaje = (desviacionConsumoLitros / combustibleTeoricoLitros) * 100
```

---

## 10. Recomendaciones para la implementación

1. **Parametrizar los coeficientes:** no hardcodearlos; almacenarlos en una tabla `ConfiguracionRendimiento` con versión.
2. **Documentar siempre las unidades:** en el nombre del campo, en `@Measures.Unit` y en comentarios.
3. **Validar rangos:** evitar distancias, pesos o rendimientos imposibles.
4. **Recalcular idempotentemente:** los valores derivados deben poder reconstruirse a partir de los datos fuente.
5. **Probar con datos reales:** comparar el consumo teórico con el real de varios viajes para validar el modelo.
6. **Incluir el `rendimientoBase` del vehículo:** usarlo como referencia o como una variable más del modelo.

---

*Fin del documento.*
