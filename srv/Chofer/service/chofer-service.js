const cds = require("@sap/cds");
const { SELECT } = require("@sap/cds/lib/ql/cds-ql");

module.exports = async (srv) => {
    const { Choferes, Viajes } = cds.entities('ConfigService');

    srv.before(["CREATE", "UPDATE"], Choferes, async (req) => {

        if (req.data.cedula) {
            const filtro = { cedula: req.data.cedula };
            if (req.data.ID) filtro.ID = { '!=': req.data.ID };
            const existe = await SELECT.one.from(Choferes).where(filtro);
            if (existe) {
                req.error(400, `Ya existe un chofer registrado con la cédula ${req.data.cedula}`);
            }
        }

   
        if (req.data.telefono && !/^\d{11}$/.test(req.data.telefono)) {
            req.error(400, 'El teléfono debe tener exactamente 11 dígitos numéricos');
        }

    
        if (req.data.cedula && req.data.cedula.trim().length < 7) {
            req.error(400, 'La cédula debe tener al menos 7 caracteres');
        }
    });

    srv.before("DELETE", Choferes, async (req) => {
        const viajeActivo = await SELECT.one.from(Viajes).where({ 
            chofer_ID: req.data.ID,
            estado_code: 'EnCurso'
        });
        if (viajeActivo) {
            req.error(400, 'No se puede eliminar un chofer que tiene un viaje activo');
        }
    });
};