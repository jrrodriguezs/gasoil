(function () {
    "use strict";

    /* controller for custom card  */
    // Controller : https://ui5.sap.com/#/topic/121b8e6337d147af9819129e428f1f75
    // controller class name can be like app.ovp.ext.customList.CustomList where app.ovp can be replaced with your application namespace
    sap.ui.define(["sap/ui/model/json/JSONModel"], function(JSONModel) {
        return {
            SERVICE_URL: "/odata/v4/config/",
            onInit: async function () {
                const data = await this.getKPIs();
                const oTilesTest = new JSONModel(data);

                if (this.getView) {
                    this.getView().setModel(oTilesTest, "KPIModel");
                }
                if (this.getOwnerComponent && this.getOwnerComponent()) {
                    this.getOwnerComponent().setModel(oTilesTest, "KPIModel");

                }
                sap.ui.getCore().setModel(oTilesTest, "KPIModel");
            },
    
            onAfterRendering: function () {},

            onExit: function () {},

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
                    avgPerformance: this.NumberFormat(avgPerformance[0].rendimientoPromedioGeneral),
                    fuelCostPerKm: this.NumberFormat(fuelCostPerKm[0].precioPromedioCombustible),
                    plannedVsActual: Number(plannedVsActual[0].variacionPorcentual).toFixed(1),
                    criticalTankCount: criticalTankCount[0].cantidad,
                    driverRating: this.NumberFormat(driverRating)
                }
            },

            async getAvgPerformance (){
                const f = await fetch(this.SERVICE_URL + "PerformanceAvg");
                const d = await f.json();
                return d.value
            },

            async getFuelCostPerKm (){
                const f = await fetch(this.SERVICE_URL + "CostoCombustiblePromedio");
                const d = await f.json();
                return d.value
            },

            async getPlannedVsActual(){
                const f = await fetch(this.SERVICE_URL + "PerformancePlannedVSReal");
                const d = await f.json();
                return d.value
            },

            async getCriticalTankCount(){
                const f = await fetch(this.SERVICE_URL + "TankCritical");
                const d = await f.json();
                return d.value
            },

            async getDriverRating(){
                return 88;
            },

            NumberFormat(value) {
                try {
                    return Number(value).toFixed(2);
                } catch (error) {
                    throw new Error("Invalid number format: " + value);
                }
            }

        }
    });
})();
