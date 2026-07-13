sap.ui.define([
  "sap/ui/core/mvc/ControllerExtension"
], function (ControllerExtension) {
  "use strict";

  function _log(sMsg, oData) {
    // eslint-disable-next-line no-console
    console.log("[RutaObjectPage] " + sMsg, oData || "");
  }

  return ControllerExtension.extend("rutamaint.ext.controller.RutaObjectPage", {

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

    _findMapView: function (oControl) {
      if (!oControl) {
        return null;
      }

      if (oControl.isA && oControl.isA("sap.ui.core.mvc.XMLView") &&
          oControl.getViewName && oControl.getViewName() === "rutamaint.ext.view.MapaRutaView") {
        return oControl;
      }

      if (oControl.findAggregatedObjects) {
        var aFound = oControl.findAggregatedObjects(true, function (oObj) {
          return oObj.isA && oObj.isA("sap.ui.core.mvc.XMLView") &&
            oObj.getViewName && oObj.getViewName() === "rutamaint.ext.view.MapaRutaView";
        });
        if (aFound && aFound.length > 0) {
          return aFound[0];
        }
      }

      return null;
    }
  });
});
