sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/PlanningCalendarView",
    "sap/ui/unified/library",
    "sap/m/MessageToast",
    "sap/ui/core/format/DateFormat"
], function (Controller, JSONModel, PlanningCalendarView, unifiedLibrary, MessageToast, DateFormat) {
    "use strict";

    var ESTADOS_FILTRO = ["Programado", "EnCurso", "Finalizado"];
    var CalendarIntervalType = unifiedLibrary.CalendarIntervalType;

    return Controller.extend("calendarioviajes.controller.Calendario", {

        onInit: function () {
            this._oCal = this.byId("planningCalendar");
            this._sPeriodo = "semana";
            this._oFechaReferencia = new Date();
            this._bPrimeraCarga = true;
            this._bAplicandoVista = false;

            this._oCalModel = new JSONModel({ rows: [] });
            this.getView().setModel(this._oCalModel, "calendario");

            this._crearVistasPersonalizadas();

            var oRango = this._calcularRango(this._sPeriodo, this._oFechaReferencia);
            this._aplicarVistaPeriodo(this._sPeriodo);
            this._oCal.setStartDate(oRango.inicio);
            this._actualizarTextoRango(oRango.inicio, oRango.fin);

            this._cargarViajes();
        },

        onPeriodoChange: function (oEvent) {
            this._sPeriodo = oEvent.getParameter("key") || oEvent.getSource().getSelectedKey();
            this._bPrimeraCarga = false;
            var oRango = this._calcularRango(this._sPeriodo, this._oFechaReferencia);
            this._aplicarVistaPeriodo(this._sPeriodo);
            this._oCal.setStartDate(oRango.inicio);
            this._actualizarTextoRango(oRango.inicio, oRango.fin);
            this._cargarViajes();
        },

        onStartDateChange: function (oEvent) {
            this._oFechaReferencia = oEvent.getParameter("date") || new Date();
            this._bPrimeraCarga = false;
            var oRango = this._calcularRango(this._sPeriodo, this._oFechaReferencia);
            this._actualizarTextoRango(oRango.inicio, oRango.fin);
            this._cargarViajes();
        },

        onViewChange: function (oEvent) {
            if (this._bAplicandoVista) {
                return;
            }
            var sViewKey = oEvent.getParameter("viewKey");
            var mPeriodo = {
                week: "semana",
                month: "mes",
                quarter: "trimestre",
                year: "anio"
            };
            var sNuevoPeriodo = mPeriodo[sViewKey];
            if (!sNuevoPeriodo || sNuevoPeriodo === this._sPeriodo) {
                return;
            }
            this._sPeriodo = sNuevoPeriodo;
            var oSelector = this.byId("periodoSelector");
            if (oSelector) {
                oSelector.setSelectedKey(this._sPeriodo);
            }
            var oRango = this._calcularRango(this._sPeriodo, this._oFechaReferencia);
            this._actualizarTextoRango(oRango.inicio, oRango.fin);
            this._cargarViajes();
        },

        onAppointmentSelect: function (oEvent) {
            var oAppointment = oEvent.getParameter("appointment");
            if (!oAppointment) {
                return;
            }
            var oCtx = oAppointment.getBindingContext("calendario");
            if (!oCtx) {
                MessageToast.show("No se encontró el contexto del viaje");
                return;
            }
            var oAppointmentData = oCtx.getObject();
            if (!oAppointmentData || !oAppointmentData.viaje) {
                MessageToast.show("No hay datos del viaje disponibles");
                return;
            }
            this._abrirDialogoViaje(oAppointmentData.viaje);
        },

        onCloseDialog: function () {
            var oDialog = this.byId("viajeDialog");
            if (oDialog) {
                oDialog.close();
            }
        },

        _abrirDialogoViaje: function (oViaje) {
            var oDialog = this.byId("viajeDialog");
            if (!oDialog) {
                MessageToast.show("No se encontró el diálogo");
                return;
            }
            var oDatos = this._prepararDatosDialogo(oViaje);
            if (!this._oDialogModel) {
                this._oDialogModel = new JSONModel();
                this.getView().setModel(this._oDialogModel, "dialog");
            }
            this._oDialogModel.setData(oDatos);
            oDialog.open();
        },

        _prepararDatosDialogo: function (oViaje) {
            var oVehiculo = oViaje.vehiculo || {};
            return {
                numeroViajeFormateado: oViaje.numeroViajeFormateado || String(oViaje.numeroViaje || ""),
                nombreRuta: oViaje.nombreRuta || "—",
                choferNombreCompleto: oViaje.choferNombreCompleto || "—",
                placa: oVehiculo.placa || "—",
                estatus: oViaje.estatus || "—",
                estatusEstado: this._mapEstatusEstado(oViaje.estatus),
                horaSalida: this._formatearFechaHora(oViaje.horaSalida),
                horaLlegada: this._formatearFechaHora(oViaje.horaLlegada),
                horaLlegadaReal: this._formatearFechaHora(oViaje.horaLlegadaReal),
                origen: oViaje.origen || "—",
                destino: oViaje.destino || "—",
                kilometrosRecorridos: this._formatearNumero(oViaje.kilometrosRecorridos) + " km",
                consumoRealTotal: this._formatearNumero(oViaje.consumoRealTotal) + " L"
            };
        },

        _mapEstatusEstado: function (sEstatus) {
            switch (sEstatus) {
                case "EnCurso": return "Success";
                case "Finalizado": return "Information";
                case "Cancelado": return "Error";
                default: return "None";
            }
        },

        _formatearFechaHora: function (vFecha) {
            if (!vFecha) {
                return "—";
            }
            var oFmt = DateFormat.getDateTimeInstance({ pattern: "dd/MM/yyyy HH:mm" });
            return oFmt.format(new Date(vFecha));
        },

        _formatearNumero: function (vNumero) {
            var fNum = parseFloat(vNumero);
            if (isNaN(fNum)) {
                return "0.00";
            }
            return fNum.toFixed(2);
        },

        _cargarViajes: function () {
            var oRango = this._calcularRango(this._sPeriodo, this._oFechaReferencia);
            var sUrl = this._construirUrl(oRango.inicio, oRango.fin);

            fetch(sUrl, { headers: { "Accept": "application/json" } })
                .then(function (oResponse) {
                    if (!oResponse.ok) {
                        throw new Error("Error HTTP " + oResponse.status);
                    }
                    return oResponse.json();
                })
                .then(function (oJson) {
                    this._renderizarViajes(oJson.value || []);
                }.bind(this))
                .catch(function (err) {
                    console.error("Error cargando viajes:", err);
                    MessageToast.show("Error al cargar los viajes");
                });
        },

        _construirUrl: function (dInicio, dFin) {
            var sFiltroEstados = ESTADOS_FILTRO.map(function (s) {
                return "'" + s + "'";
            }).join(",");

            var sInicio = dInicio.toISOString();
            var sFin = dFin.toISOString();

            var aFiltros = [
                "estatus in (" + sFiltroEstados + ")",
                "horaSalida ge " + sInicio,
                "horaSalida le " + sFin
            ];

            var sSelect = "ID,estatus,horaSalida,horaLlegada,horaLlegadaReal,nombreRuta,choferNombreCompleto,vehiculo_ID,vehiculo/placa,origen,destino,kilometrosRecorridos,consumoRealTotal,numeroViaje,numeroViajeFormateado";
            var sExpand = "vehiculo";
            var sOrder = "horaSalida";

            return "/odata/v4/config/Viajes?$filter=" + encodeURIComponent(aFiltros.join(" and ")) +
                "&$select=" + encodeURIComponent(sSelect) +
                "&$expand=" + encodeURIComponent(sExpand) +
                "&$orderby=" + encodeURIComponent(sOrder) +
                "&$top=5000";
        },

        _renderizarViajes: function (aViajes) {
            var mFilas = {};
            var aFilas = [];

            aViajes.forEach(function (oViaje) {
                var sPlaca = (oViaje.vehiculo && oViaje.vehiculo.placa) || this._getTextoSinVehiculo();
                if (!mFilas[sPlaca]) {
                    mFilas[sPlaca] = {
                        placa: sPlaca,
                        appointments: []
                    };
                    aFilas.push(mFilas[sPlaca]);
                }

                var oStart = this._parseFecha(oViaje.horaSalida);
                var oEnd = this._parseFecha(oViaje.horaLlegadaReal || oViaje.horaLlegada || oViaje.horaSalida);
                if (!oEnd || oEnd <= oStart) {
                    oEnd = new Date(oStart.getTime() + 60 * 60 * 1000);
                }

                var sTitle = (oViaje.nombreRuta || "Ruta") + " - " + (oViaje.choferNombreCompleto || "Sin chofer");
                var sType = oViaje.estatus === "EnCurso" ? "Type08" : "Type01";

                mFilas[sPlaca].appointments.push({
                    startDate: oStart,
                    endDate: oEnd,
                    title: sTitle,
                    text: oViaje.estatus,
                    type: sType,
                    viaje: oViaje
                });
            }.bind(this));

            aFilas.sort(function (a, b) {
                return a.placa.localeCompare(b.placa);
            });

            this._oCalModel.setProperty("/rows", aFilas);

            if (aFilas.length === 0 && this._bPrimeraCarga) {
                this._intentarAjustarAFechaConDatos();
            } else {
                this._bPrimeraCarga = false;
            }
        },

        _intentarAjustarAFechaConDatos: function () {
            var sFiltroEstados = ESTADOS_FILTRO.map(function (s) { return "'" + s + "'"; }).join(",");
            var sUrl = "/odata/v4/config/Viajes?$filter=" + encodeURIComponent("estatus in (" + sFiltroEstados + ")") +
                "&$select=" + encodeURIComponent("horaSalida") +
                "&$orderby=" + encodeURIComponent("horaSalida desc") +
                "&$top=1";

            fetch(sUrl, { headers: { "Accept": "application/json" } })
                .then(function (oResponse) { return oResponse.json(); })
                .then(function (oJson) {
                    var aValores = oJson.value || [];
                    if (aValores.length > 0 && aValores[0].horaSalida) {
                        this._oFechaReferencia = new Date(aValores[0].horaSalida);
                        var oRango = this._calcularRango(this._sPeriodo, this._oFechaReferencia);
                        this._oCal.setStartDate(oRango.inicio);
                        this._actualizarTextoRango(oRango.inicio, oRango.fin);
                        this._cargarViajes();
                    }
                    this._bPrimeraCarga = false;
                }.bind(this))
                .catch(function () {
                    this._bPrimeraCarga = false;
                }.bind(this));
        },

        _calcularRango: function (sPeriodo, dRef) {
            var dInicio, dFin;
            var d = new Date(dRef.getFullYear(), dRef.getMonth(), dRef.getDate(), 0, 0, 0);

            switch (sPeriodo) {
                case "semana":
                    var iDia = d.getDay();
                    dInicio = new Date(d.getFullYear(), d.getMonth(), d.getDate() - iDia, 0, 0, 0);
                    dFin = new Date(dInicio.getFullYear(), dInicio.getMonth(), dInicio.getDate() + 7, 0, 0, 0);
                    break;
                case "mes":
                    dInicio = new Date(d.getFullYear(), d.getMonth(), 1, 0, 0, 0);
                    dFin = new Date(d.getFullYear(), d.getMonth() + 1, 1, 0, 0, 0);
                    break;
                case "trimestre":
                    var iTrimestre = Math.floor(d.getMonth() / 3);
                    dInicio = new Date(d.getFullYear(), iTrimestre * 3, 1, 0, 0, 0);
                    dFin = new Date(d.getFullYear(), iTrimestre * 3 + 3, 1, 0, 0, 0);
                    break;
                case "anio":
                    dInicio = new Date(d.getFullYear(), 0, 1, 0, 0, 0);
                    dFin = new Date(d.getFullYear() + 1, 0, 1, 0, 0, 0);
                    break;
                default:
                    dInicio = new Date(d.getFullYear(), d.getMonth(), 1, 0, 0, 0);
                    dFin = new Date(d.getFullYear(), d.getMonth() + 1, 1, 0, 0, 0);
            }

            return { inicio: dInicio, fin: dFin };
        },

        _crearVistasPersonalizadas: function () {
            this._oCal.addView(new PlanningCalendarView({
                key: "week",
                intervalType: CalendarIntervalType.Day,
                description: "Semana",
                intervalsS: 7,
                intervalsM: 7,
                intervalsL: 7
            }));
            this._oCal.addView(new PlanningCalendarView({
                key: "month",
                intervalType: CalendarIntervalType.Month,
                description: "Mes",
                intervalsS: 1,
                intervalsM: 1,
                intervalsL: 1
            }));
            this._oCal.addView(new PlanningCalendarView({
                key: "quarter",
                intervalType: CalendarIntervalType.Month,
                description: "Trimestre",
                intervalsS: 3,
                intervalsM: 3,
                intervalsL: 3
            }));
            this._oCal.addView(new PlanningCalendarView({
                key: "year",
                intervalType: CalendarIntervalType.Month,
                description: "Año",
                intervalsS: 12,
                intervalsM: 12,
                intervalsL: 12
            }));
        },

        _aplicarVistaPeriodo: function (sPeriodo) {
            var mVista = {
                semana: "week",
                mes: "month",
                trimestre: "quarter",
                anio: "year"
            };
            var sViewKey = mVista[sPeriodo] || "month";
            this._bAplicandoVista = true;
            this._oCal.setViewKey(sViewKey);
            this._bAplicandoVista = false;
        },

        _actualizarTextoRango: function (dInicio, dFin) {
            var oFmt = DateFormat.getDateInstance({ pattern: "dd/MM/yyyy" });
            var sTexto = oFmt.format(dInicio) + " - " + oFmt.format(new Date(dFin.getTime() - 1));
            var oText = this.byId("rangoPeriodo");
            if (oText) {
                oText.setText(sTexto);
            }
        },

        _parseFecha: function (vFecha) {
            if (!vFecha) {
                return new Date();
            }
            return new Date(vFecha);
        },

        _getTextoSinVehiculo: function () {
            var oBundle = this.getOwnerComponent().getModel("i18n").getResourceBundle();
            return oBundle.getText("sinVehiculo");
        }
    });
});
