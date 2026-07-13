sap.ui.define([
  'sap/ui/core/mvc/ControllerExtension'
], function (ControllerExtension) {
  'use strict';

  return ControllerExtension.extend('reportes.ext.controller.ListReportExt', {

    onInit: function () {
      setTimeout(function () {
        this._addExportButton();
      }.bind(this), 0);
    },

    _addExportButton: function () {
      sap.ui.require(['sap/m/Button'], function (Button) {
        var oView = this.base.getView();
        if (!oView) {
          return;
        }
        var aPages = oView.findElements(true, function (oElement) {
          return oElement.isA && oElement.isA('sap.f.DynamicPage');
        });
        if (!aPages || !aPages.length) {
          return;
        }
        var oPage = aPages[0];
        var oTitle = oPage.getTitle();
        if (!oTitle || !oTitle.getActions) {
          return;
        }
        var aActions = oTitle.getActions();
        if (aActions.some(function (oAction) {
          return oAction.getId && oAction.getId().indexOf('exportPDF') !== -1;
        })) {
          return;
        }
        oTitle.addAction(new Button({
          id: oView.createId('exportPDFButton'),
          text: 'Exportar PDF',
          icon: 'sap-icon://pdf-text',
          type: 'Emphasized',
          press: this.onExportarPDF.bind(this)
        }));
      }.bind(this));
    },

    onExportarPDF: async function () {
      try {
        sap.ui.require(['sap/m/MessageToast'], function (MessageToast) {
          MessageToast.show('Generando PDF, por favor espere...');
        });

        await this._cargarLibreriasPDF();
        const aDatos = await this._obtenerDatosReporte();
        this._generarPDF(aDatos);
      } catch (err) {
        console.error('Error exportando PDF:', err);
        sap.ui.require(['sap/m/MessageToast'], function (MessageToast) {
          MessageToast.show('Error al generar el PDF');
        });
      }
    },

    _cargarLibreriasPDF: function () {
      if (window.jspdf && window.jspdf.jsPDF && window.jspdf.jsPDF.API.autoTable) {
        return Promise.resolve();
      }

      var sBaseUrl = sap.ui.require.toUrl('reportes/thirdparty/');

      return this._cargarScript(sBaseUrl + 'jspdf.js')
        .then(function () {
          return this._cargarScript(sBaseUrl + 'jspdf-autotable.js');
        }.bind(this));
    },

    _cargarScript: function (sUrl) {
      return new Promise(function (resolve, reject) {
        var oScript = document.createElement('script');
        oScript.src = sUrl;
        oScript.onload = resolve;
        oScript.onerror = function () {
          reject(new Error('No se pudo cargar ' + sUrl));
        };
        document.head.appendChild(oScript);
      });
    },

    _obtenerDatosReporte: async function () {
      var sTableId = 'reportes::HechosViajeReportesList--fe::table::HechosViajeReportes::LineItem';
      var oView = this.base.getView();
      var oTable = oView.byId(sTableId);

      if (oTable) {
        var oBinding = oTable.getRowBinding();
        if (oBinding && oBinding.requestCount) {
          var iTotal = await oBinding.requestCount();
          var iChunk = 1000;
          var aPromises = [];
          for (var iFrom = 0; iFrom < iTotal; iFrom += iChunk) {
            aPromises.push(oBinding.requestContexts(iFrom, iChunk, '$auto.page_' + iFrom));
          }
          var aResultados = await Promise.all(aPromises);
          var aContextos = aResultados.flat();
          return aContextos.map(function (oContext) {
            return oContext.getObject();
          });
        }
      }

      // Fallback: leer todos los hechos directamente
      var sUrl = '/odata/v4/reporting/HechosViajeReportes?$select=fecha,placaVehiculo,nombreChofer,descripcionRuta,distanciaKm,litrosSalida,consumoRealTotal,consumoTeoricoTotal,rendimientoReal,rendimientoTeorico,costoTeorico,costoPorKm,estadoViaje&$top=5000';
      var oResponse = await fetch(sUrl, { headers: { 'Accept': 'application/json' } });
      if (!oResponse.ok) {
        throw new Error('Error leyendo datos del reporte');
      }
      var oJson = await oResponse.json();
      return oJson.value || [];
    },

    _generarPDF: function (aDatos) {
      var { jsPDF } = window.jspdf;
      var doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' });

      // Cabecera del reporte
      var sTitulo = 'Reporte de Hechos de Viaje';
      var sDescripcion = 'Reporte detallado de los viajes finalizados, incluyendo indicadores de rendimiento, consumo de combustible y costos asociados.';
      var sFechaEmision = 'Fecha de emisión: ' + new Date().toLocaleDateString('es-ES', { year: 'numeric', month: 'long', day: 'numeric' });
      var sUsuario = 'Usuario: ' + this._obtenerUsuario();

      doc.setFontSize(16);
      doc.text(sTitulo, 14, 18);

      doc.setFontSize(10);
      doc.text(sDescripcion, 14, 26, { maxWidth: 270 });
      doc.text(sFechaEmision, 14, 34);
      doc.text(sUsuario, 14, 40);

      // Columnas
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
    },

    _obtenerUsuario: function () {
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
});
