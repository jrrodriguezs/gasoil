(function () {
    "use strict";

    /* controller for custom card  */
    // Controller : https://ui5.sap.com/#/topic/121b8e6337d147af9819129e428f1f75
    // controller class name can be like app.ovp.ext.customList.CustomList where app.ovp can be replaced with your application namespace
    sap.ui.define(["sap/ui/model/json/JSONModel"], function(JSONModel) {
        return {
            onInit: async function () {
                try {
                    const data = await this.getChoferes();
                    const oModel = new JSONModel({
                        choferes:data
                    });
                    this.getView().setModel(oModel, "choferesModel");
                } catch (error) {
                    console.error("Error al cargar choferes:", error);
                    this.getView().setModel(new JSONModel({ choferes: [] }), "choferesModel");
                }
            },
    
            onAfterRendering: function () {},

            onExit: function () {},

            _getModel: function() {
                var oModel;
                if (this.getView && this.getView()) {
                    oModel = this.getView().getModel("mainModel");
                }
                if (!oModel && this.getOwnerComponent && this.getOwnerComponent()) {
                    oModel = this.getOwnerComponent().getModel("mainModel");
                }
                if (!oModel) {
                    oModel = sap.ui.getCore().getModel("mainModel");
                }
                return oModel;
            },

            _readEntity: function(sPath, mUrlParameters) {
                return new Promise(function(resolve, reject) {
                    var oModel = this._getModel();
                    if (!oModel) {
                        reject(new Error("Modelo mainModel no disponible"));
                        return;
                    }
                    oModel.read(sPath, {
                        urlParameters: mUrlParameters || {},
                        success: function(oData) {
                            resolve(oData.results || oData);
                        },
                        error: function(oError) {
                            reject(oError);
                        }
                    });
                }.bind(this));
            },

            async getChoferes(){
                try {
                    const d = await this._readEntity("/Choferes", { "$top": "7" });
                    return d.map(chofer => ({
                        ...chofer,
                        rendimientoRating: this.rendimientoFormat(chofer.rendimiento_code)
                    })).sort((a,b) => b.rendimientoRating - a.rendimientoRating);
                } catch (error) {
                    console.error("Error al obtener choferes:", error);
                    return [];
                }
            },

            rendimientoFormat(value) {
                if (value == "Malo"){
                    return 2;
                }
                if (value == "Regular"){
                    return 3
                }
                if (value == "Bueno"){
                    return 5;
                }
                return 0;
            }

        }
    });
})();
