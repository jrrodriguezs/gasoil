// eslint-disable-next-line no-console
console.log("[ViajeObjectPage] Módulo de extensión cargado");

sap.ui.define([
  "sap/ui/core/mvc/ControllerExtension",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/ui/core/Core",
  "sap/m/MessageToast"
], function (ControllerExtension, Filter, FilterOperator, Core, MessageToast) {
  "use strict";

  function _log(sMsg, oData) {
    // eslint-disable-next-line no-console
    console.log("[ViajeObjectPage] " + sMsg, oData || "");
  }

  function _formatNumeroViaje(iNumero) {
    var n = Number(iNumero) || 0;
    return String(n).padStart(5, "0");
  }

  return ControllerExtension.extend("viajesmaint.ext.controller.ViajeObjectPage", {

    override: {
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
        _log("Ruta y viaje para header", { rutaId: sRutaId, viajeId: sViajeId });
        // Actualizar el título del header con nombre de ruta y número de viaje
        this._updateHeaderTitle(oContext);
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

    _updateHeaderTitle: function (oContext) {
      var that = this;
      var oView = this.base && this.base.getView ? this.base.getView() : null;
      var oModel = oView ? oView.getModel() : null;
      if (!oView || !oModel || !oContext) {
        return;
      }

      var sViajeId = oContext.getProperty("ID");
      if (!sViajeId) {
        _log("No se encontró el ID del viaje para actualizar el header");
        return;
      }

      // Se solicitan explícitamente el número de viaje formateado y el destino de la ruta
      // porque el binding por defecto del ObjectPage no los incluye en el header.
      var oBinding = oModel.bindList("/Viajes", null, [], [
        new Filter("ID", FilterOperator.EQ, sViajeId)
      ], {
        $select: "numeroViaje,numeroViajeFormateado,ruta_ID",
        $expand: "ruta($select=destino)"
      });

      oBinding.requestContexts(0, 1).then(function (aContexts) {
        if (!aContexts || aContexts.length === 0) {
          return;
        }
        var oData = aContexts[0].getObject();
        var sNombreRuta = oData.ruta && oData.ruta.destino ? oData.ruta.destino : "";
        // Se usa el valor formateado del backend; si no estuviera disponible, se calcula localmente.
        var sNumeroFormateado = oData.numeroViajeFormateado || _formatNumeroViaje(oData.numeroViaje);
        _log("Datos para header obtenidos", { nombreRuta: sNombreRuta, numeroViaje: oData.numeroViaje, numeroFormateado: sNumeroFormateado });
        that._setHeaderTitle(sNombreRuta, sNumeroFormateado, true);
      }).catch(function (oErr) {
        _log("Error obteniendo datos para header", oErr);
      });
    },

    _setHeaderTitle: function (sNombreRuta, sNumeroViaje, bYaFormateado, iIntentos) {
      var that = this;
      var oView = this.base && this.base.getView ? this.base.getView() : null;
      if (!oView) {
        return;
      }

      iIntentos = iIntentos || 0;
      var MAX_INTENTOS = 30;

      var oObjectPage = this._findObjectPageLayout(oView);
      if (!oObjectPage) {
        if (iIntentos < MAX_INTENTOS) {
          _log("ObjectPageLayout no encontrado, reintentando...", iIntentos);
          setTimeout(function () {
            that._setHeaderTitle(sNombreRuta, sNumeroViaje, bYaFormateado, iIntentos + 1);
          }, 200);
        } else {
          _log("No se encontró ObjectPageLayout para actualizar el header después de " + MAX_INTENTOS + " intentos");
        }
        return;
      }

      var oHeader = oObjectPage.getHeaderTitle();
      if (!oHeader) {
        if (iIntentos < MAX_INTENTOS) {
          _log("Título del header no encontrado, reintentando...", iIntentos);
          setTimeout(function () {
            that._setHeaderTitle(sNombreRuta, sNumeroViaje, bYaFormateado, iIntentos + 1);
          }, 200);
        } else {
          _log("No se encontró el título del header después de " + MAX_INTENTOS + " intentos");
        }
        return;
      }

      var sNumeroFormateado = bYaFormateado ? sNumeroViaje : _formatNumeroViaje(sNumeroViaje);

      if (oHeader.setObjectTitle) {
        oHeader.setObjectTitle(sNombreRuta || "");
      }
      if (oHeader.setObjectSubtitle) {
        oHeader.setObjectSubtitle(sNumeroFormateado);
      }
      MessageToast.show("Viaje " + sNumeroFormateado + " - " + sNombreRuta, {
        duration: 2000,
        width: "20em"
      });
      _log("Header actualizado", { titulo: sNombreRuta, subtitulo: sNumeroFormateado });
    },

    _findObjectPageLayout: function (oControl) {
      if (!oControl) {
        return null;
      }

      if (oControl.isA && oControl.isA("sap.uxap.ObjectPageLayout")) {
        return oControl;
      }

      // Buscar en los agregados de la vista
      if (oControl.findAggregatedObjects) {
        var aFound = oControl.findAggregatedObjects(true, function (oObj) {
          return oObj.isA && oObj.isA("sap.uxap.ObjectPageLayout");
        });
        if (aFound && aFound.length > 0) {
          return aFound[0];
        }
      }

      // Buscar en el contenido de la vista
      if (oControl.getContent) {
        var aContent = oControl.getContent ? oControl.getContent() : [];
        if (aContent && aContent.length) {
          for (var i = 0; i < aContent.length; i++) {
            var oFound = this._findObjectPageLayout(aContent[i]);
            if (oFound) {
              return oFound;
            }
          }
        }
      }

      // Buscar por ID relativo en la vista
      var oById = oControl.byId ? oControl.byId("fe::ObjectPage") : null;
      if (oById && oById.isA && oById.isA("sap.uxap.ObjectPageLayout")) {
        return oById;
      }

      // Último recurso: buscar en el Core por tipo
      var aAll = Core.getControls ? Core.getControls() : [];
      for (var j = 0; j < aAll.length; j++) {
        if (aAll[j].isA && aAll[j].isA("sap.uxap.ObjectPageLayout")) {
          return aAll[j];
        }
      }

      return null;
    }
  });
});
