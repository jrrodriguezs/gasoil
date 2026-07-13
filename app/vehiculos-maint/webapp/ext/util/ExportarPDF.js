sap.ui.define([], function () {
  "use strict";

  function _cargarScript(sUrl) {
    return fetch(sUrl)
      .then(function (oResponse) {
        if (!oResponse.ok) {
          throw new Error("HTTP " + oResponse.status + " en " + sUrl);
        }
        return oResponse.text();
      })
      .then(function (sCode) {
        var fnEjecutar = new Function("define", "exports", "module", sCode + "\n//# sourceURL=" + sUrl);
        fnEjecutar(undefined, undefined, undefined);
      });
  }

  function _cargarLibrerias() {
    if (window.jspdf && window.jspdf.jsPDF && window.jspdf.jsPDF.API.autoTable) {
      return Promise.resolve();
    }
    var sBaseUrl = sap.ui.require.toUrl("vehiculosmaint/thirdparty/");
    return _cargarScript(sBaseUrl + "jspdf.js").then(function () {
      return _cargarScript(sBaseUrl + "jspdf-autotable.js");
    });
  }

  function _formatearFecha(sFecha) {
    if (!sFecha) return "";
    var d = new Date(sFecha);
    if (isNaN(d.getTime())) return sFecha;
    return d.toLocaleDateString("es-ES", { year: "numeric", month: "2-digit", day: "2-digit" });
  }

  function _numero(v) {
    if (v === null || v === undefined || v === "") return "";
    var n = Number(v);
    return isNaN(n) ? v : n.toFixed(2);
  }

  return {
    exportar: function (oDatos) {
      return _cargarLibrerias().then(function () {
        var jsPDFModule = window.jspdf;
        var doc = new jsPDFModule.jsPDF({ orientation: "portrait", unit: "mm", format: "a4" });

        var v = oDatos.vehiculo || {};
        var c = oDatos.chofer || {};
        var ind = oDatos.indicadores || {};
        var aViajes = oDatos.viajes || [];

        var sTitulo = "Ficha técnica del vehículo";
        var sSubtitulo = (v.placa || "") + " - " + (v.modelo || "");
        var sFecha = "Fecha de emisión: " + new Date().toLocaleDateString("es-ES", { year: "numeric", month: "long", day: "numeric" });

        doc.setFontSize(16);
        doc.text(sTitulo, 14, 18);
        doc.setFontSize(12);
        doc.text(sSubtitulo, 14, 25);
        doc.setFontSize(10);
        doc.text(sFecha, 14, 32);

        // Datos maestros
        var aDatosMaestros = [
          ["Placa", v.placa || ""],
          ["Modelo", v.modelo || ""],
          ["Estado", v.estadodelvehiculo_code || ""],
          ["Configuración", v.configuraciondelremolque || ""],
          ["Ejes", v.ejescamion_code || ""],
          ["Número de tanques", _numero(v.numeroTanques)],
          ["Capacidad total", _numero(v.capacidadTotal) + " L"],
          ["Nivel combustible", _numero(v.nivelActualCombustible) + " L"],
          ["Rendimiento base", _numero(v.rendimientoBase) + " " + (v.measure_code || "km/l")],
          ["Rendimiento real", _numero(v.promedioKm) + " " + (v.measure_code || "km/l")],
          ["Carga útil", _numero(v.cargautil) + " t"],
          ["Km totales", _numero(v.kmTotales) + " km"],
          ["Litros totales", _numero(v.litrosTotales) + " L"]
        ];

        doc.autoTable({
          body: aDatosMaestros,
          startY: 38,
          theme: "plain",
          styles: { fontSize: 9, cellPadding: 1 },
          columnStyles: { 0: { fontStyle: "bold", cellWidth: 55 } }
        });

        // Chofer
        var y = doc.lastAutoTable.finalY + 6;
        doc.setFontSize(12);
        doc.text("Datos del chofer", 14, y);
        doc.autoTable({
          body: [
            ["Nombre", (c.nombre || "") + " " + (c.apellido || "")],
            ["Cédula", c.cedula || ""],
            ["Teléfono", c.telefono || ""],
            ["Dirección", c.direccion || ""]
          ],
          startY: y + 3,
          theme: "plain",
          styles: { fontSize: 9, cellPadding: 1 },
          columnStyles: { 0: { fontStyle: "bold", cellWidth: 55 } }
        });

        // Indicadores
        y = doc.lastAutoTable.finalY + 6;
        doc.setFontSize(12);
        doc.text("Indicadores de gestión", 14, y);
        doc.autoTable({
          body: [
            ["Eficiencia vs. base", _numero(ind.eficienciaPct) + "%"],
            ["Promedio km/l", _numero(ind.promedioKm)],
            ["Promedio consumo", _numero(ind.promedioConsumo)],
            ["Total viajes", _numero(aViajes.length)]
          ],
          startY: y + 3,
          theme: "plain",
          styles: { fontSize: 9, cellPadding: 1 },
          columnStyles: { 0: { fontStyle: "bold", cellWidth: 55 } }
        });

        // Viajes
        y = doc.lastAutoTable.finalY + 6;
        doc.setFontSize(12);
        doc.text("Últimos viajes", 14, y);

        var aHead = ["Fecha", "Ruta", "Distancia", "Litros", "Consumo", "Estatus"];
        var aBody = aViajes.map(function (oV) {
          return [
            _formatearFecha(oV.fecha),
            oV.nombreRuta || (oV.ruta && oV.ruta.destino) || "",
            _numero(oV.kilometrosRecorridos),
            _numero(oV.litrosSalida),
            _numero(oV.consumoRealTotal),
            oV.estatus || ""
          ];
        });

        doc.autoTable({
          head: [aHead],
          body: aBody,
          startY: y + 4,
          styles: { fontSize: 8, cellPadding: 1.2, overflow: "linebreak" },
          headStyles: { fillColor: [0, 76, 153], textColor: 255, fontStyle: "bold" },
          alternateRowStyles: { fillColor: [245, 245, 245] },
          margin: { left: 14, right: 14 },
          didDrawPage: function (data) {
            doc.setFontSize(8);
            doc.setTextColor(128);
            doc.text("Página " + data.pageNumber, 14, doc.internal.pageSize.height - 10);
          }
        });

        doc.save("ficha_tecnica_" + (v.placa || "vehiculo") + ".pdf");
      });
    }
  };
});
