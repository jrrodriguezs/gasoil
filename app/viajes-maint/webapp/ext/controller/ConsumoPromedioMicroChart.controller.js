sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/suite/ui/microchart/ComparisonMicroChart",
  "sap/suite/ui/microchart/ComparisonMicroChartData",
  "sap/m/Text"
], function (Controller, ComparisonMicroChart, ComparisonMicroChartData, Text) {
  "use strict";

  function _log(sMsg, oData) {
    // eslint-disable-next-line no-console
    console.log("[ConsumoPromedioMicroChart] " + sMsg, oData || "");
  }

  return Controller.extend("viajesmaint.ext.controller.ConsumoPromedioMicroChart", {

    onInit: function () {
      _log("onInit ejecutado");
      this._bDataLoaded = false;
      this._oRetryTimeout = null;
      this._iRetries = 0;
      this._MAX_RETRIES = 20;

      var oView = this.getView();
      var that = this;
      oView.addEventDelegate({
        onAfterRendering: function () {
          _log("onAfterRendering");
          if (!that._bDataLoaded) {
            that._scheduleLoad();
          }
        }
      }, oView);
    },

    onExit: function () {
      if (this._oRetryTimeout) {
        clearTimeout(this._oRetryTimeout);
        this._oRetryTimeout = null;
      }
    },

    _scheduleLoad: function () {
      var that = this;
      if (this._oRetryTimeout) {
        clearTimeout(this._oRetryTimeout);
      }
      this._oRetryTimeout = setTimeout(function () {
        that._loadData();
      }, 300);
    },

    _retryLoad: function () {
      var that = this;
      if (this._iRetries >= this._MAX_RETRIES) {
        _log("Máximo de reintentos alcanzado");
        return;
      }
      this._iRetries++;
      if (this._oRetryTimeout) {
        clearTimeout(this._oRetryTimeout);
      }
      this._oRetryTimeout = setTimeout(function () {
        that._loadData();
      }, 500);
    },

    _loadData: function () {
      var that = this;
      var oView = this.getView();
      var oContext = this._findContext(oView);
      if (!oContext) {
        _log("No hay contexto de binding");
        this._retryLoad();
        return;
      }

      var sPath = oContext.getPath ? oContext.getPath() : null;
      if (!sPath) {
        _log("El contexto no tiene path");
        this._retryLoad();
        return;
      }

      this._iRetries = 0;

      // Primero intentamos leer los valores del contexto existente
      var fPromedioCtx = oContext.getProperty("consumoPromedioRuta");
      var fUltimoCtx = oContext.getProperty("consumoUltimoViajeRuta");
      _log("Valores del contexto", { promedio: fPromedioCtx, ultimo: fUltimoCtx });

      if (fPromedioCtx !== undefined && fPromedioCtx !== null && fUltimoCtx !== undefined && fUltimoCtx !== null) {
        that._bDataLoaded = true;
        that._renderChart(Number(fPromedioCtx) || 0, Number(fUltimoCtx) || 0);
        return;
      }

      // Si no están en el contexto, hacemos una petición explícita
      var oModel = oView.getModel();
      if (!oModel) {
        _log("No se encontró el modelo OData");
        return;
      }

      try {
        var oBinding = oModel.bindContext(sPath, null, {
          $select: "ID,consumoPromedioRuta,consumoUltimoViajeRuta"
        });
        if (oBinding && typeof oBinding.requestObject === "function") {
          oBinding.requestObject().then(function (oObject) {
            if (!oObject) {
              _log("El objeto del contexto está vacío");
              return;
            }
            var fPromedio = oObject.consumoPromedioRuta || 0;
            var fUltimo = oObject.consumoUltimoViajeRuta || 0;
            _log("Datos cargados por request", { promedio: fPromedio, ultimo: fUltimo });
            that._bDataLoaded = true;
            that._renderChart(fPromedio, fUltimo);
          }).catch(function (oErr) {
            _log("Error al solicitar objeto del contexto", oErr);
          });
        } else {
          _log("El binding no soporta requestObject");
        }
      } catch (oErr) {
        _log("Error creando binding enriquecido", oErr);
      }
    },

    _renderChart: function (fPromedio, fUltimo) {
      var oView = this.getView();
      var oContainer = oView.byId("chartContainer");
      if (!oContainer) {
        _log("No se encontró el contenedor");
        return;
      }

      oContainer.removeAllItems();

      // Diagnóstico visible con los valores
      oContainer.addItem(new Text({
        text: "Promedio: " + fPromedio + " L / Último: " + fUltimo + " L",
        class: "sapUiSmallMargin"
      }));

      if (fPromedio === 0 && fUltimo === 0) {
        oContainer.addItem(new Text({
          text: "No hay datos de consumo para comparar.",
          class: "sapUiSmallMargin"
        }));
        _log("Sin datos para comparar");
        return;
      }

      try {
        var oChart = new ComparisonMicroChart({
          width: "100%",
          size: "L"
        });

        oChart.addData(new ComparisonMicroChartData({
          title: "Promedio",
          value: fPromedio,
          displayValue: fPromedio + " L"
        }));

        oChart.addData(new ComparisonMicroChartData({
          title: "Último",
          value: fUltimo,
          displayValue: fUltimo + " L"
        }));

        oContainer.addItem(oChart);
        _log("Chart renderizado");
      } catch (oErr) {
        _log("Error renderizando chart", oErr);
        oContainer.addItem(new Text({ text: "Error al renderizar chart: " + (oErr.message || oErr) }));
      }
    },

    _findContext: function (oControl) {
      if (!oControl) {
        return null;
      }
      var oContext = oControl.getBindingContext ? oControl.getBindingContext() : null;
      var sPath = oContext && oContext.getPath ? oContext.getPath() : "";
      if (oContext && sPath.indexOf("/Viajes(") === 0) {
        return oContext;
      }
      if (oControl.getParent) {
        return this._findContext(oControl.getParent());
      }
      return null;
    }
  });
});
