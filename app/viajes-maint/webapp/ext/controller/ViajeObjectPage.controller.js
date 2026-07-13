// eslint-disable-next-line no-console
console.log("[ViajeObjectPage] Módulo de extensión cargado");

sap.ui.define([
  "sap/ui/core/mvc/ControllerExtension",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/ui/model/json/JSONModel"
], function (ControllerExtension, Filter, FilterOperator, JSONModel) {
  "use strict";

  function _log(sMsg, oData) {
    // eslint-disable-next-line no-console
    console.log("[ViajeObjectPage] " + sMsg, oData || "");
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

  return ControllerExtension.extend("viajesmaint.ext.controller.ViajeObjectPage", {

    onInit: function () {
      _log("onInit ejecutado");
      var oView = this.base && this.base.getView ? this.base.getView() : null;
      if (!oView) {
        _log("No se encontró la vista base");
        return;
      }

      this._oRetryTimeout = null;
      this._iMapViewRetries = 0;
      this._MAX_MAP_VIEW_RETRIES = 600;
      this._sLastContextPath = null;

      // Modelo local para los micro charts del header
      oView.setModel(new JSONModel({
        ultimosConsumos: [],
        consumosPorVehiculo: []
      }), "headerCharts");

      var that = this;
      oView.addEventDelegate({
        onAfterRendering: function () {
          _log("onAfterRendering de ObjectPage");
          that._propagateContext();
        }
      }, oView);
    },

    onExit: function () {
      if (this._oRetryTimeout) {
        clearTimeout(this._oRetryTimeout);
        this._oRetryTimeout = null;
      }
    },

    _propagateContext: function () {
      var that = this;
      var oView = this.base && this.base.getView ? this.base.getView() : null;
      if (!oView) {
        return;
      }

      if (this._oRetryTimeout) {
        clearTimeout(this._oRetryTimeout);
        this._oRetryTimeout = null;
      }

      var oContext = oView.getBindingContext ? oView.getBindingContext() : null;
      _log("Contexto del ObjectPage", oContext);
      if (!oContext) {
        if (this._iMapViewRetries < this._MAX_MAP_VIEW_RETRIES) {
          this._iMapViewRetries++;
          this._oRetryTimeout = setTimeout(function () {
            that._propagateContext();
          }, 500);
        }
        return;
      }

      var sPath = oContext.getPath ? oContext.getPath() : null;
      if (sPath && sPath === this._sLastContextPath) {
        _log("Mismo contexto, se omite carga de charts");
      } else {
        this._sLastContextPath = sPath;
        var sRutaId = oContext.getProperty("ruta_ID");
        var sViajeId = oContext.getProperty("ID");
        _log("Ruta y viaje para charts", { rutaId: sRutaId, viajeId: sViajeId });
        if (sRutaId && sViajeId) {
          this._loadHeaderCharts(sRutaId, sViajeId);
        }
      }

      var oMapView = this._findMapView(oView);
      _log("Vista del mapa encontrada", oMapView ? "sí" : "no");
      if (oMapView && oMapView.setBindingContext) {
        var oModel = oView.getModel ? oView.getModel() : null;
        if (oModel && oMapView.setModel) {
          oMapView.setModel(oModel);
        }
        oMapView.setBindingContext(oContext);
        _log("Contexto pasado a MapaRutaView");
        this._iMapViewRetries = 0;
      } else if (this._iMapViewRetries < this._MAX_MAP_VIEW_RETRIES) {
        this._iMapViewRetries++;
        this._oRetryTimeout = setTimeout(function () {
          that._propagateContext();
        }, 500);
      }
    },

    _loadHeaderCharts: function (sRutaId, sViajeId) {
      var that = this;
      var oView = this.base.getView();
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
        that._updateHeaderChartsModel("ultimosConsumos", aUltimosConsumos);
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
        that._updateHeaderChartsModel("consumosPorVehiculo", aConsumosPorVehiculo.slice(0, 3));
      }).catch(function (oErr) {
        _log("Error cargando consumos por vehículo", oErr);
      });
    },

    _updateHeaderChartsModel: function (sProperty, aData) {
      var oView = this.base.getView();
      var oModel = oView.getModel("headerCharts");
      if (!oModel) {
        return;
      }
      var oData = oModel.getData();
      oData[sProperty] = aData;
      oModel.setData(oData);
    },

    _findMapView: function (oControl) {
      if (!oControl) {
        return null;
      }

      if (oControl.isA && oControl.isA("sap.ui.core.mvc.XMLView") &&
          oControl.getViewName && oControl.getViewName() === "viajesmaint.ext.view.MapaRutaView") {
        return oControl;
      }

      if (oControl.findAggregatedObjects) {
        var aFound = oControl.findAggregatedObjects(true, function (oObj) {
          return oObj.isA && oObj.isA("sap.ui.core.mvc.XMLView") &&
            oObj.getViewName && oObj.getViewName() === "viajesmaint.ext.view.MapaRutaView";
        });
        if (aFound && aFound.length > 0) {
          return aFound[0];
        }
      }

      return null;
    }
  });
});
