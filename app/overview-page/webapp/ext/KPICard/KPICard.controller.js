(function () {
    "use strict";

    /* controller for custom card  */
    // Controller : https://ui5.sap.com/#/topic/121b8e6337d147af9819129e428f1f75
    // controller class name can be like app.ovp.ext.customList.CustomList where app.ovp can be replaced with your application namespace
    sap.ui.define(["sap/ui/model/json/JSONModel"], function(JSONModel) {
        return {
            onInit: async function () {
                try {
                    const data = await this.getKPIs();
                    const oTilesTest = new JSONModel(data);

                    if (this.getView) {
                        this.getView().setModel(oTilesTest, "KPIModel");
                    }
                    if (this.getOwnerComponent && this.getOwnerComponent()) {
                        this.getOwnerComponent().setModel(oTilesTest, "KPIModel");
                    }
                    sap.ui.getCore().setModel(oTilesTest, "KPIModel");
                } catch (error) {
                    const oFallbackModel = new JSONModel({
                        avgPerformance: "N/A",
                        fuelCostPerKm: "N/A",
                        plannedVsActual: "N/A",
                        criticalTankCount: "N/A",
                        driverRating: "N/A"
                    });
                    if (this.getView) {
                        this.getView().setModel(oFallbackModel, "KPIModel");
                    }
                    if (this.getOwnerComponent && this.getOwnerComponent()) {
                        this.getOwnerComponent().setModel(oFallbackModel, "KPIModel");
                    }
                    sap.ui.getCore().setModel(oFallbackModel, "KPIModel");
                    console.error("Error al inicializar KPIs:", error);
                }
            },
    
            onAfterRendering: function () {},

            onExit: function () {},

            _getModel: function() {
                var oModel;
                if (this.getView && this.getView()) {
                    oModel = this.getView().getModel("mainModel") || this.getView().getModel();
                }
                if (!oModel && this.getOwnerComponent && this.getOwnerComponent()) {
                    var oComp = this.getOwnerComponent();
                    while (oComp) {
                        oModel = oComp.getModel("mainModel") || oComp.getModel();
                        if (oModel) {
                            break;
                        }
                        oComp = oComp.getOwnerComponent ? oComp.getOwnerComponent() : null;
                    }
                }
                if (!oModel) {
                    oModel = sap.ui.getCore().getModel("mainModel") || sap.ui.getCore().getModel();
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

            async getKPIs() {
                const promises = [
                    this.getAvgPerformance(),
                    this.getFuelCostPerKm(),
                    this.getPlannedVsActual(),
                    this.getCriticalTankCount(),
                    this.getDriverRating()
                ];
                const [
                    avgPerformance, 
                    fuelCostPerKm, 
                    plannedVsActual, 
                    criticalTankCount, 
                    driverRating
                ] = await Promise.all(promises);

                return {
                    avgPerformance: this.NumberFormat(avgPerformance[0]?.rendimientoPromedioGeneral),
                    fuelCostPerKm: this.NumberFormat(fuelCostPerKm[0]?.costoPorKm),
                    plannedVsActual: Number(plannedVsActual[0]?.variacionPorcentual).toFixed(1),
                    criticalTankCount: criticalTankCount[0]?.cantidad,
                    driverRating: this.NumberFormat(driverRating)
                }
            },

            async getAvgPerformance (){
                try {
                    const d = await this._readEntity("/PerformanceAvg");
                    return d;
                } catch (error) {
                    console.error("Error al obtener rendimiento promedio:", error);
                    return [{ rendimientoPromedioGeneral: "N/A" }];
                }
            },

            async getFuelCostPerKm (){
                try {
                    const d = await this._readEntity("/CostoCombustiblePromedio");
                    return d;
                } catch (error) {
                    console.error("Error al obtener costo de combustible:", error);
                    return [{ precioPromedioCombustible: "N/A" }];
                }
            },

            async getPlannedVsActual(){
                try {
                    const d = await this._readEntity("/PerformancePlannedVSReal");
                    return d;
                } catch (error) {
                    console.error("Error al obtener planned vs actual:", error);
                    return [{ variacionPorcentual: "N/A" }];
                }
            },

            async getCriticalTankCount(){
                try {
                    const d = await this._readEntity("/TankCritical");
                    return d;
                } catch (error) {
                    console.error("Error al obtener tanques críticos:", error);
                    return [{ cantidad: "N/A" }];
                }
            },

            async getDriverRating(){
                try {
                    const d = await this._readEntity("/DriverRating");
                    return d[0]?.calificacionPromedioConductores ?? "N/A";
                } catch (error) {
                    console.error("Error al obtener driver rating:", error);
                    return "N/A";
                }
            },

            NumberFormat(value) {
                if (value === "N/A" || value === undefined || value === null || isNaN(value)) {
                    return "N/A";
                }
                try {
                    return Number(value).toFixed(2);
                } catch (error) {
                    return "N/A";
                }
            }

        }
    });
})();
