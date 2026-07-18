sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/suite/ui/microchart/ColumnMicroChart",
  "sap/suite/ui/microchart/ColumnMicroChartData",
  "sap/m/Text"
], function (Controller, Filter, FilterOperator, ColumnMicroChart, ColumnMicroChartData, Text) {
  "use strict";

  function _log(sMsg, oData) {
    // eslint-disable-next-line no-console
    console.log("[HeaderChartsView] " + sMsg, oData || "");
  }

  function _formatDate(sDate) {
    if (!sDate) {
      return "";
    }
    var oDate = new Date(sDate);
    if (isNaN(oDate.getTime())) {
      return String(sDate);
    }
    return oDate.toLocaleDateString("es-ES", {
      day: "2-digit",
      month: "2-digit"
    });
  }

  function _formatConsumo(vConsumo) {
    var fConsumo = parseFloat(vConsumo) || 0;
    return fConsumo.toFixed(2);
  }

  return Controller.extend("viajesmaint.ext.controller.HeaderChartsView", {

    onInit: function () {
      _log("onInit ejecutado");
      this._bDataLoaded = false;
      this._iRetries = 0;
      this._MAX_RETRIES = 20;
      this._oRetryTimeout = null;

      var oView = this.getView();

      var that = this;
      oView.addEventDelegate({
        onAfterRendering: function () {
          _log("onAfterRendering del HeaderChartsView");
          if (!that._bDataLoaded) {
            that._scheduleLoad();
          } else if (that._aLastColumnas) {
            // Si el contenedor quedó vacío tras un re-render, volver a pintar
            var oContainer = oView.byId("chartContainer");
            if (oContainer && oContainer.getItems().length === 0) {
              that._renderColumnChart(that._aLastColumnas);
            }
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
        _log("Máximo de reintentos alcanzado, no se pudo cargar el contexto");
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
      _log("Contexto encontrado (path)", sPath);

      if (!sPath) {
        _log("El contexto no tiene path");
        this._retryLoad();
        return;
      }

      // Contexto válido: reseteamos reintentos
      this._iRetries = 0;

      var oModel = oView.getModel();
      if (!oModel) {
        _log("No se encontró el modelo OData");
        return;
      }

      // Asegurar que tenemos ruta_ID e ID haciendo un binding enriquecido
      try {
        var oBinding = oModel.bindContext(sPath, null, {
          $select: "ID,ruta_ID"
        });
        if (oBinding && typeof oBinding.requestObject === "function") {
          oBinding.requestObject().then(function (oObject) {
            if (!oObject) {
              _log("El objeto del contexto está vacío");
              return;
            }
            var sRutaId = oObject.ruta_ID;
            var sViajeId = oObject.ID;
            _log("Propiedades del contexto", { rutaId: sRutaId, viajeId: sViajeId });

            if (!sRutaId || !sViajeId) {
              _log("Faltan ruta_ID o ID");
              return;
            }

            that._bDataLoaded = true;
            that._loadCharts(sRutaId, sViajeId);
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

    _loadCharts: function (sRutaId, sViajeId) {
      var that = this;
      var oView = this.getView();
      var oModel = oView.getModel();
      if (!oModel) {
        _log("No se encontró el modelo OData");
        return;
      }

      // Últimos 5 consumos de la ruta (cualquier vehículo, excluyendo el viaje actual)
      var oBinding = oModel.bindList("/Viajes", null, [], [
        new Filter("ruta_ID", FilterOperator.EQ, sRutaId),
        new Filter("ID", FilterOperator.NE, sViajeId)
      ], {
        $orderby: "fecha desc",
        $select: "fecha,consumoRealTotal"
      });

      oBinding.requestContexts(0, 5).then(function (aContexts) {
        // Ordenar cronológicamente ascendente (del más antiguo al más reciente)
        var aConsumos = aContexts.map(function (oCtx) {
          return oCtx.getObject();
        }).sort(function (a, b) {
          return new Date(a.fecha) - new Date(b.fecha);
        });

        var aColumnas = that._mapearColumnas(aConsumos);
        that._aLastColumnas = aColumnas;
        _log("Columnas del chart cargadas", aColumnas);
        that._renderColumnChart(aColumnas);
      }).catch(function (oErr) {
        _log("Error cargando últimos consumos", oErr);
      });
    },

    _mapearColumnas: function (aConsumos) {
      if (!aConsumos || aConsumos.length === 0) {
        return [];
      }

      return aConsumos.map(function (oData) {
        return {
          fecha: _formatDate(oData.fecha),
          consumo: oData.consumoRealTotal || 0
        };
      });
    },

    _renderColumnChart: function (aColumnas) {
      var oView = this.getView();
      var oContainer = oView.byId("chartContainer");
      if (!oContainer) {
        _log("No se encontró el contenedor del chart");
        return;
      }

      oContainer.removeAllItems();

      if (!aColumnas || aColumnas.length === 0) {
        oContainer.addItem(new Text({
          text: "No hay consumos previos disponibles para esta ruta.",
          class: "sapUiSmallMargin"
        }));
        _log("Sin columnas para renderizar");
        return;
      }

      try {
        var aChartColumns = aColumnas.map(function (oColumna) {
          var sConsumo = _formatConsumo(oColumna.consumo);
          return new ColumnMicroChartData({
            title: oColumna.fecha,
            value: oColumna.consumo,
            displayValue: sConsumo + " L"
          });
        });

        var oChart = new ColumnMicroChart({
          width: "100%",
          size: "L",
          columns: aChartColumns
        });

        oContainer.addItem(oChart);
        _log("Chart renderizado con columnas", aColumnas);
      } catch (oErr) {
        _log("Error renderizando chart", oErr);
        oContainer.addItem(new Text({
          text: "Error al renderizar chart: " + (oErr.message || oErr),
          class: "sapUiSmallMargin"
        }));
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
