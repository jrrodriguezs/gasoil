(function () {
    "use strict";

    /* controller for custom card  */
    // Controller : https://ui5.sap.com/#/topic/121b8e6337d147af9819129e428f1f75
    // controller class name can be like app.ovp.ext.customList.CustomList where app.ovp can be replaced with your application namespace
    sap.ui.define(["sap/ui/model/json/JSONModel"], function (JSONModel) {
        return {
            onInit: function () {
                this._loadKPIs();
            },

            onAfterRendering: function () {},

            onExit: function () {},

            _loadKPIs: async function () {
                try {
                    const [avgPerformance, fuelCost, plannedVsActual, criticalTanks, driverRating] = await Promise.all([
                        this._fetchData("/odata/v2/config/PerformanceAvg?$format=json"),
                        this._fetchData("/odata/v2/config/CostoCombustiblePromedio?$format=json"),
                        this._fetchData("/odata/v2/config/PerformancePlannedVSReal?$format=json"),
                        this._fetchData("/odata/v2/config/TankCritical?$format=json"),
                        this._fetchData("/odata/v2/config/DriverRating?$format=json")
                    ]);

                    const data = {
                        avgPerformance: this._formatNumber(avgPerformance?.d?.results?.[0]?.rendimientoPromedioGeneral),
                        fuelCostPerKm: this._formatNumber(fuelCost?.d?.results?.[0]?.costoPorKm),
                        plannedVsActual: this._formatNumber(plannedVsActual?.d?.results?.[0]?.variacionPorcentual, 1),
                        criticalTankCount: this._formatInteger(criticalTanks?.d?.results?.[0]?.cantidad),
                        driverRating: this._formatNumber(driverRating?.d?.results?.[0]?.calificacionPromedioConductores)
                    };

                    this._setKPIModel(data);
                } catch (error) {
                    console.error("Error al cargar KPIs:", error);
                    this._setKPIModel({
                        avgPerformance: "N/A",
                        fuelCostPerKm: "N/A",
                        plannedVsActual: "N/A",
                        criticalTankCount: "N/A",
                        driverRating: "N/A"
                    });
                }
            },

            _fetchData: async function (sUrl) {
                const response = await fetch(sUrl, {
                    method: "GET",
                    headers: {
                        "Accept": "application/json"
                    }
                });
                if (!response.ok) {
                    throw new Error("Error HTTP " + response.status + " en " + sUrl);
                }
                return response.json();
            },

            _formatNumber: function (value, decimals) {
                decimals = decimals || 2;
                if (value === undefined || value === null || value === "" || isNaN(value)) {
                    return "N/A";
                }
                return Number(value).toFixed(decimals);
            },

            _formatInteger: function (value) {
                if (value === undefined || value === null || value === "" || isNaN(value)) {
                    return "N/A";
                }
                return Number(value).toString();
            },

            _setKPIModel: function (data) {
                const oModel = new JSONModel(data);
                if (this.getView && this.getView()) {
                    this.getView().setModel(oModel, "KPIModel");
                }
                if (this.getOwnerComponent && this.getOwnerComponent()) {
                    this.getOwnerComponent().setModel(oModel, "KPIModel");
                }
                sap.ui.getCore().setModel(oModel, "KPIModel");
            }
        };
    });
})();
