const cds = require("@sap/cds");

async function migrate() {
  try {
    await cds.connect.to("db");

    // Obtener todos los viajes ordenados por fecha de creación (los más antiguos primero)
    // Nota: SQLite devuelve los nombres de columna en minúsculas.
    const viajes = await SELECT.from("gas.app.Viaje").columns("ID", "numeroViaje").orderBy({ createdAt: "asc", ID: "asc" });

    let maxNumero = 0;
    const sinNumero = viajes.filter(v => v.numeroviaje == null || v.numeroviaje === "" || Number(v.numeroviaje) === 0);

    if (sinNumero.length === 0) {
      console.log("Todos los viajes ya tienen número asignado.");
    } else {
      // Calcular el máximo actual
      const maxResult = await SELECT.one.from("gas.app.Viaje").columns("max(numeroViaje) as maxNumero");
      maxNumero = maxResult && maxResult.maxnumero ? Number(maxResult.maxnumero) : 0;

      console.log(`Asignando números a ${sinNumero.length} viajes sin número (máximo actual: ${maxNumero})...`);

      for (const viaje of sinNumero) {
        maxNumero++;
        const formateado = String(maxNumero).padStart(5, "0");
        await UPDATE("gas.app.Viaje").set({ numeroViaje: maxNumero, numeroViajeFormateado: formateado }).where({ ID: viaje.id });
        console.log(`  Viaje ${viaje.id} → ${formateado}`);
      }
    }

    // Sincronizar el formateado para todos los viajes que tengan número
    const conNumero = viajes.filter(v => v.numeroviaje != null && v.numeroviaje !== "" && Number(v.numeroviaje) > 0);
    for (const viaje of conNumero) {
      const esperado = String(Number(viaje.numeroviaje)).padStart(5, "0");
      await UPDATE("gas.app.Viaje").set({ numeroViajeFormateado: esperado }).where({ ID: viaje.id });
    }
    console.log(`Sincronizados ${conNumero.length} viajes con número.`);
    console.log("Migración finalizada.");
  } catch (error) {
    console.error("Error en migración:", error);
    process.exit(1);
  }
}

migrate();
