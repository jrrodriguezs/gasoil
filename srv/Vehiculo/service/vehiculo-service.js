function vehiculoHandler(service) {
    const { Vehiculos } = service.entities;

    /**
     * Calcula capacidadTotal para CREATE y UPDATE (incluyendo Drafts)
     *   capacidadTotal = capacidadTanque1 + (numeroTanques > 1 ? capacidadTanque2 : 0)
     * Para UPDATE, si req.data.ID existe, se obtiene el registro actual para usar los valores
     * no presentes en el payload. Si numeroTanques == 1 se ignora/fuerza capacidadTanque2 = 0.
     */
    service.before(['CREATE', 'UPDATE'], [Vehiculos, Vehiculos.drafts], async (req) => {
        if (!req.data) return;

        let data = req.data;

        // En UPDATE podemos estar trabajando con un solo objeto; normalizamos a array
        const entries = Array.isArray(data) ? data : [data];

        for (const entry of entries) {
            let numeroTanques = entry.numeroTanques;
            let capacidadTanque1 = entry.capacidadTanque1;
            let capacidadTanque2 = entry.capacidadTanque2;

            // Si estamos en UPDATE y hay ID, buscar valores actuales para los que no vienen en el payload
            if (req.event === 'UPDATE' && entry.ID) {
                const current = await SELECT.one.from(Vehiculos).where({ ID: entry.ID });
                if (current) {
                    if (numeroTanques === undefined) numeroTanques = current.numeroTanques;
                    if (capacidadTanque1 === undefined) capacidadTanque1 = current.capacidadTanque1;
                    if (capacidadTanque2 === undefined) capacidadTanque2 = current.capacidadTanque2;
                }
            }

            // Asegurar que si numeroTanques es 1, capacidadTanque2 sea 0 (o se ignore)
            if (numeroTanques === 1) {
                capacidadTanque2 = 0;
            }

            // Calcular capacidadTotal si tenemos los datos necesarios
            if (numeroTanques !== undefined && capacidadTanque1 !== undefined) {
                const tanque2 = (numeroTanques > 1 && capacidadTanque2 !== undefined) ? capacidadTanque2 : 0;
                entry.capacidadTotal = Number(capacidadTanque1) + Number(tanque2);
            }
        }
    });
}

module.exports = vehiculoHandler;
