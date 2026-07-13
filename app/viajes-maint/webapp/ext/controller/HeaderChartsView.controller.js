sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/ui/model/json/JSONModel"
], function (Controller, Filter, FilterOperator, JSONModel) {
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
      month: "2-digit",
      year: "numeric"
    });
  }

  return Controller.extend("viajesmaint.ext.controller.HeaderChartsView", {

    onInit: function () {
      _log("onInit ejecutado");
      this._bDataLoaded = false;
      this._iRetries = 0;
      this._MAX_RETRIES = 20;
      this._oRetryTimeout = null;

      var oView = this.getView();
      oView.setModel(new JSONModel({
        ultimosConsumos: [],
        consumosPorVehiculo: []
      }), "headerCharts");

      var that = this;
      oView.addEventDelegate({
        onAfterRendering: function () {
          _log("onAfterRendering del HeaderChartsView");
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

      // Últimos 3 consumos de la ruta (cualquier vehículo, excluyendo el viaje actual)
      var oBinding1 = oModel.bindList("/Viajes", null, [], [
        new Filter("ruta_ID", FilterOperator.EQ, sRutaId),
        new Filter("ID", FilterOperator.NE, sViajeId)
      ], {
        $orderby: "fecha desc",
        $select: "fecha,consumoRealTotal"
      });

      oBinding1.requestContexts(0, 3).then(function (aContexts) {
        var aUltimosConsumos = aContexts.map(function (oCtx) {
          var oData = oCtx.getObject();
          return {
            fecha: _formatDate(oData.fecha),
            consumo: oData.consumoRealTotal || 0
          };
        });
        _log("Últimos consumos cargados", aUltimosConsumos);
        that._updateModel("ultimosConsumos", aUltimosConsumos);
      }).catch(function (oErr) {
        _log("Error cargando últimos consumos", oErr);
      });

      // Últimos 3 vehículos distintos en la ruta
      var oBinding2 = oModel.bindList("/Viajes", null, [], [
        new Filter("ruta_ID", FilterOperator.EQ, sRutaId),
        new Filter("ID", FilterOperator.NE, sViajeId)
      ], {
        $orderby: "fecha desc",
        $select: "fecha,consumoRealTotal,vehiculo_ID",
        $expand: "vehiculo($select=placa)"
      });

      oBinding2.requestContexts(0, 100).then(function (aContexts) {
        var mVehiculos = {};
        var aConsumosPorVehiculo = [];
        aContexts.forEach(function (oCtx) {
          var oData = oCtx.getObject();
          var sVehiculoId = oData.vehiculo_ID;
          if (sVehiculoId && !mVehiculos[sVehiculoId]) {
            mVehiculos[sVehiculoId] = true;
            aConsumosPorVehiculo.push({
              placa: oData.vehiculo && oData.vehiculo.placa ? oData.vehiculo.placa : sVehiculoId,
              consumo: oData.consumoRealTotal || 0
            });
          }
        });
        _log("Consumos por vehículo cargados", aConsumosPorVehiculo);
        that._updateModel("consumosPorVehiculo", aConsumosPorVehiculo.slice(0, 3));
      }).catch(function (oErr) {
        _log("Error cargando consumos por vehículo", oErr);
      });
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
    },

    _updateModel: function (sProperty, aData) {
      var oView = this.getView();
      var oModel = oView.getModel("headerCharts");
      if (!oModel) {
        return;
      }
      var oData = oModel.getData();
      oData[sProperty] = aData;
      oModel.setData(oData);
    }
  });
});
