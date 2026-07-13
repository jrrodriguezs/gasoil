sap.ui.define([], function () {
  'use strict';

  return {
    onExportarPDF: async function () {
      try {
        sap.ui.require(['sap/m/MessageToast'], function (MessageToast) {
          MessageToast.show('Generando PDF, por favor espere...');
        });

        await _cargarLibreriasPDF();
        var aDatos = await _obtenerDatosReporte();
        _generarPDF(aDatos);
      } catch (err) {
        console.error('Error exportando PDF:', err);
        sap.ui.require(['sap/m/MessageToast'], function (MessageToast) {
          MessageToast.show('Error al generar el PDF');
        });
      }
    }
  };

  function _cargarLibreriasPDF() {
    if (window.jspdf && window.jspdf.jsPDF && window.jspdf.jsPDF.API.autoTable) {
      return Promise.resolve();
    }

    var sBaseUrl = sap.ui.require.toUrl('reportes/thirdparty/');

    return _cargarScript(sBaseUrl + 'jspdf.js')
      .then(function () {
        return _cargarScript(sBaseUrl + 'jspdf-autotable.js');
      });
  }

  function _cargarScript(sUrl) {
    return fetch(sUrl)
      .then(function (oResponse) {
        if (!oResponse.ok) {
          throw new Error('HTTP ' + oResponse.status + ' en ' + sUrl);
        }
        return oResponse.text();
      })
      .then(function (sCode) {
        // Forzar la rama global del UMD ocultando define/exports/module,
        // de lo contrario SAPUI5/RequireJS lo registra como módulo AMD
        // y no se expone window.jspdf.
        var fnEjecutar = new Function('define', 'exports', 'module', sCode + '\n//# sourceURL=' + sUrl);
        fnEjecutar(undefined, undefined, undefined);
      });
  }

  async function _obtenerDatosReporte() {
    var sUrl = '/odata/v4/reporting/HechosViajeReportes?$select=fecha,placaVehiculo,nombreChofer,descripcionRuta,distanciaKm,litrosSalida,consumoRealTotal,consumoTeoricoTotal,rendimientoReal,rendimientoTeorico,costoTeorico,costoPorKm,estadoViaje&$top=5000';
    var oResponse = await fetch(sUrl, { headers: { 'Accept': 'application/json' } });
    if (!oResponse.ok) {
      throw new Error('Error leyendo datos del reporte');
    }
    var oJson = await oResponse.json();
    return oJson.value || [];
  }

  function _generarPDF(aDatos) {
    var jsPDFModule = window.jspdf;
    var doc = new jsPDFModule.jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' });

    var sTitulo = 'Reporte de Hechos de Viaje';
    var sDescripcion = 'Reporte detallado de los viajes finalizados, incluyendo indicadores de rendimiento, consumo de combustible y costos asociados.';
    var sFechaEmision = 'Fecha de emisión: ' + new Date().toLocaleDateString('es-ES', { year: 'numeric', month: 'long', day: 'numeric' });
    var sUsuario = 'Usuario: ' + _obtenerUsuario();

    doc.setFontSize(16);
    doc.text(sTitulo, 14, 18);

    doc.setFontSize(10);
    doc.text(sDescripcion, 14, 26, { maxWidth: 270 });
    doc.text(sFechaEmision, 14, 34);
    doc.text(sUsuario, 14, 40);

    var aColumnas = [
      { key: 'fecha', label: 'Fecha', width: 22 },
      { key: 'placaVehiculo', label: 'Placa', width: 22 },
      { key: 'nombreChofer', label: 'Chofer', width: 42 },
      { key: 'descripcionRuta', label: 'Ruta', width: 42 },
      { key: 'distanciaKm', label: 'Distancia (km)', width: 24 },
      { key: 'litrosSalida', label: 'Litros', width: 18 },
      { key: 'consumoRealTotal', label: 'Consumo Real', width: 24 },
      { key: 'rendimientoReal', label: 'Rend. Real', width: 20 },
      { key: 'costoPorKm', label: 'Costo/km', width: 20 },
      { key: 'estadoViaje', label: 'Estado', width: 24 }
    ];

    var aHead = aColumnas.map(function (oCol) { return oCol.label; });
    var aBody = aDatos.map(function (oFila) {
      return aColumnas.map(function (oCol) {
        var vValor = oFila[oCol.key];
        if (oCol.key === 'fecha' && vValor) {
          return new Date(vValor).toLocaleDateString('es-ES');
        }
        if (vValor === null || vValor === undefined) {
          return '';
        }
        if (typeof vValor === 'number') {
          return vValor.toFixed(2);
        }
        return vValor.toString();
      });
    });

    var oColumnStyles = {};
    aColumnas.forEach(function (oCol, iIndex) {
      oColumnStyles[iIndex] = { cellWidth: oCol.width };
    });

    doc.autoTable({
      head: [aHead],
      body: aBody,
      startY: 46,
      styles: {
        fontSize: 7,
        cellPadding: 1.2,
        overflow: 'linebreak'
      },
      headStyles: {
        fillColor: [0, 76, 153],
        textColor: 255,
        fontStyle: 'bold'
      },
      alternateRowStyles: {
        fillColor: [245, 245, 245]
      },
      columnStyles: oColumnStyles,
      margin: { left: 14, right: 14 },
      didDrawPage: function (data) {
        doc.setFontSize(8);
        doc.setTextColor(128);
        doc.text('Página ' + data.pageNumber, 14, doc.internal.pageSize.height - 10);
      }
    });

    doc.save('reporte_hechos_viaje.pdf');

    sap.ui.require(['sap/m/MessageToast'], function (MessageToast) {
      MessageToast.show('PDF descargado correctamente');
    });
  }

  function _obtenerUsuario() {
    try {
      if (sap.ushell && sap.ushell.Container && sap.ushell.Container.getUser) {
        var oUser = sap.ushell.Container.getUser();
        return oUser.getFullName() || oUser.getId() || 'Usuario';
      }
    } catch (e) {
      // ignorar
    }
    return 'Usuario';
  }
});
