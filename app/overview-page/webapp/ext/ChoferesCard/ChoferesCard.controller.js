(function () {
    "use strict";

    /* controller for custom card  */
    // Controller : https://ui5.sap.com/#/topic/121b8e6337d147af9819129e428f1f75
    // controller class name can be like app.ovp.ext.customList.CustomList where app.ovp can be replaced with your application namespace
    sap.ui.define(["sap/ui/model/json/JSONModel"], function(JSONModel) {
        return {
            SERVICE_URL: "/odata/v4/config/",
            onInit: async function () {
                const data = await this.getChoferes();
                const oModel = new JSONModel({
                    choferes:data
                });
                this.getView().setModel(oModel, "choferesModel");
                console.log(data);
                
            },
    
            onAfterRendering: function () {},

            onExit: function () {},

            async getChoferes(){
                try {
                    const r = await fetch(this.SERVICE_URL + "Choferes?$top=7");
                    const d = await r.json();
                    return d.value.map(chofer => ({
                        ...chofer,
                        rendimientoRating: this.rendimientoFormat(chofer.rendimiento_code)
                    })).sort((a,b) => b.rendimientoRating - a.rendimientoRating);
                } catch (error) {
                    throw new Error("Failed to fetch data: " + error.message);
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
            }

        }
    });
})();
