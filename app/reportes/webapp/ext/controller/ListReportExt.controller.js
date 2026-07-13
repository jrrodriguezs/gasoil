sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension"
], function (ControllerExtension) {
    "use strict";

    return ControllerExtension.extend("reportes.ext.controller.ListReportExt", {
        override: {
            onInit: function () {
                this._sincronizarYRefrescar();
            }
        },

        _sincronizarYRefrescar: function () {
            fetch("/odata/v4/reporting/sincronizar", {
                method: "POST",
                headers: { "Content-Type": "application/json" }
            })
                .then(function (oResponse) {
                    if (!oResponse.ok) {
                        throw new Error("Sincronización fallida: " + oResponse.status);
                    }
                    return oResponse.json();
                })
                .then(function () {
                    var oExtensionAPI = this.base.getExtensionAPI && this.base.getExtensionAPI();
                    if (oExtensionAPI && oExtensionAPI.refresh) {
                        oExtensionAPI.refresh();
                    } else {
                        var oModel = this.base.getView().getModel();
                        if (oModel) {
                            oModel.refresh();
                        }
                    }
                }.bind(this))
                .catch(function (oError) {
                    // Si ya hay datos sincronizados no se bloquea la UI
                    if (oError && oError.message) {
                        console.warn("[reportes] Sincronización automática:", oError.message);
                    }
                });
        }
    });
});
