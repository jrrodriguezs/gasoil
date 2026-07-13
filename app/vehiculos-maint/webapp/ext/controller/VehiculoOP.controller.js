sap.ui.define([
  "sap/ui/core/mvc/ControllerExtension",
  "sap/ui/core/Fragment",
  "sap/ui/model/json/JSONModel",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/ui/model/Sorter",
  "sap/m/MessageBox",
  "sap/base/security/URLListValidator",
  "vehiculosmaint/ext/util/ExportarPDF",
  "vehiculosmaint/ext/util/GoogleMaps"
], function (
  ControllerExtension,
  Fragment,
  JSONModel,
  Filter,
  FilterOperator,
  Sorter,
  MessageBox,
  URLListValidator,
  ExportarPDF,
  GoogleMaps
) {
  "use strict";

  return ControllerExtension.extend("vehiculosmaint.ext.controller.VehiculoOP", {

    override: {
      onInit: function () {
        // Nada por ahora
      },
      onExit: function () {
        this._destruirMapa();
        if (this._oDialog) {
          this._oDialog.destroy();
          this._oDialog = null;
        }
      }
    },

    onFichaTecnicaPress: function () {
      var oView = this.base.getView();
      var oModel = oView.getModel();
      var oContext = oView.getBindingContext();

      if (!oContext) {
        MessageBox.error("No se encontró el vehículo activo.");
        return;
      }

      var sPath = oContext.getPath();
      var that = this;

      Promise.resolve()
        .then(function () {
          return that._cargarVehiculo(oModel, sPath);
        })
        .then(function (oVehiculo) {
          return that._cargarViajes(oModel, oVehiculo.ID).then(function (aViajes) {
            return { vehiculo: oVehiculo, viajes: aViajes };
          });
        })
        .then(function (mData) {
          mData.chofer = mData.vehiculo.chofer || {};
          mData.indicadores = that._calcularIndicadores(mData.vehiculo, mData.viajes);
          return that._abrirDialogo(mData);
        })
        .catch(function (oErr) {
          MessageBox.error("Error al cargar la ficha técnica: " + (oErr.message || oErr));
          // eslint-disable-next-line no-console
          console.error(oErr);
        });
    },

    onExportarPDF: function () {
      if (!this._oFichaModel) {
        return;
      }
      ExportarPDF.exportar(this._oFichaModel.getData()).catch(function (oErr) {
        MessageBox.error("Error al exportar el PDF: " + (oErr.message || oErr));
        // eslint-disable-next-line no-console
        console.error(oErr);
      });
    },

    onCerrarFichaTecnica: function () {
      if (this._oDialog) {
        this._oDialog.close();
      }
    },

    onTabSelectSeccion: function (oEvent) {
      var oSection = oEvent.getParameter("section");
      // eslint-disable-next-line no-console
      console.log("FichaTecnica: tabSelect disparado", oSection && oSection.getId());
      if (!oSection) {
        return;
      }
      if (oSection.getId() === "fichaSeccionMapa" || oSection.getId().indexOf("fichaSeccionMapa") !== -1) {
        var aViajes = this._oFichaModel ? this._oFichaModel.getProperty("/viajes") : [];
        this._inicializarMapa(aViajes);
      }
    },

    _cargarVehiculo: function (oModel, sPath) {
      var oBinding = oModel.bindContext(sPath, undefined, {
        $expand: { chofer: {} }
      });
      return oBinding.requestObject().then(function (oVehiculo) {
        oVehiculo = oVehiculo || {};
        oVehiculo.chofer = oVehiculo.chofer || {};
        return oVehiculo;
      });
    },

    _cargarViajes: function (oModel, sVehiculoId) {
      var aFilters = [
        new Filter("vehiculo_ID", FilterOperator.EQ, sVehiculoId)
      ];
      var aSorters = [new Sorter("fecha", true)];
      var oListBinding = oModel.bindList("/Viajes", undefined, aSorters, aFilters, {
        $expand: "ruta($expand=puntos)"
      });
      return oListBinding.requestContexts(0, 20).then(function (aContexts) {
        return aContexts.map(function (oCtx) {
          return oCtx.getObject();
        });
      });
    },

    _calcularIndicadores: function (oVehiculo, aViajes) {
      var fPromedioKm = parseFloat(oVehiculo.promedioKm) || 0;
      var fRendimientoBase = parseFloat(oVehiculo.rendimientoBase) || 0;
      var fEficiencia = 0;
      if (fRendimientoBase > 0 && fPromedioKm > 0) {
        fEficiencia = ((fPromedioKm - fRendimientoBase) / fRendimientoBase) * 100;
      }

      var fTotalConsumo = 0;
      var iConConsumo = 0;
      aViajes.forEach(function (oV) {
        var c = parseFloat(oV.consumoRealTotal);
        if (!isNaN(c) && c > 0) {
          fTotalConsumo += c;
          iConConsumo++;
        }
      });
      var fPromedioConsumo = iConConsumo > 0 ? fTotalConsumo / iConConsumo : 0;

      return {
        promedioKm: fPromedioKm,
        promedioConsumo: parseFloat(fPromedioConsumo.toFixed(2)),
        eficienciaPct: parseFloat(fEficiencia.toFixed(2)),
        totalViajes: aViajes.length
      };
    },

    _abrirDialogo: function (mData) {
      var that = this;
      var oView = this.base.getView();

      if (!this._oFichaModel) {
        this._oFichaModel = new JSONModel();
        oView.setModel(this._oFichaModel, "ficha");
      }
      this._oFichaModel.setData(mData, true);

      if (this._oDialog) {
        this._oDialog.open();
        return Promise.resolve();
      }

      return Fragment.load({
        name: "vehiculosmaint.ext.fragment.FichaTecnica",
        controller: this
      }).then(function (oDialog) {
        that._oDialog = oDialog;
        oView.addDependent(oDialog);

        var oOPL = oDialog.getContent()[0];
        if (oOPL && typeof oOPL.attachTabSelect === "function") {
          oOPL.attachTabSelect(that.onTabSelectSeccion, that);
        }

        var oPanelMapa = sap.ui.getCore().byId("fichaPanelMapa");
        if (oPanelMapa) {
          oPanelMapa.addEventDelegate({
            onAfterRendering: function () {
              // eslint-disable-next-line no-console
              console.log("FichaTecnica: panel del mapa renderizado.");
              that._inicializarMapa(mData.viajes);
            }
          }, that);
        }

        oDialog.attachAfterOpen(function () {
          that._inicializarMapa(mData.viajes);
        });
        oDialog.attachAfterClose(function () {
          that._destruirMapa();
        });
        oDialog.open();
      });
    },

    _inicializarMapa: function (aViajes) {
      var that = this;
      // eslint-disable-next-line no-console
      console.log("FichaTecnica: inicializando mapa...");

      if (URLListValidator && typeof URLListValidator.add === "function") {
        URLListValidator.add("https", "maps.googleapis.com", null, null);
        URLListValidator.add("https", "*.google.com", null, null);
        URLListValidator.add("https", "*.gstatic.com", null, null);
      }

      if (this._bMapaInicializado || this._bInicializandoMapa) {
        return Promise.resolve();
      }
      this._bInicializandoMapa = true;

      return GoogleMaps.cargar().then(function (google) {
        that._oGoogle = google;
        return new Promise(function (resolve) {
          var oContainer = document.getElementById("fichaMapaRutas");
          if (!oContainer) {
            that._bInicializandoMapa = false;
            // eslint-disable-next-line no-console
            console.warn("FichaTecnica: no se encontró el contenedor del mapa.");
            resolve();
            return;
          }

          function _renderizar() {
            that._bInicializandoMapa = false;
            that._bMapaInicializado = true;
            // eslint-disable-next-line no-console
            console.log("FichaTecnica: contenedor del mapa listo, renderizando...");
            setTimeout(function () {
              that._renderizarMapaGoogle(that._oGoogle, aViajes).then(resolve).catch(resolve);
            }, 100);
          }

          if (oContainer.offsetWidth > 0 && oContainer.offsetHeight > 0) {
            _renderizar();
            return;
          }

          var iIntentos = 0;
          var iInterval;
          if (typeof window.ResizeObserver !== "undefined") {
            var oResizeObserver = new window.ResizeObserver(function (aEntries) {
              var oEntry = aEntries[0];
              if (oEntry && oEntry.contentRect && oEntry.contentRect.width > 0 && oEntry.contentRect.height > 0) {
                oResizeObserver.disconnect();
                clearInterval(iInterval);
                _renderizar();
              }
            });
            oResizeObserver.observe(oContainer);

            iInterval = setInterval(function () {
              iIntentos++;
              if (iIntentos >= 150) { // ~30 segundos
                clearInterval(iInterval);
                oResizeObserver.disconnect();
                that._bInicializandoMapa = false;
                // eslint-disable-next-line no-console
                console.warn("FichaTecnica: contenedor del mapa no disponible tras espera.");
                resolve();
              }
            }, 200);
          } else {
            iInterval = setInterval(function () {
              iIntentos++;
              if (oContainer.offsetWidth > 0 && oContainer.offsetHeight > 0) {
                clearInterval(iInterval);
                _renderizar();
              } else if (iIntentos >= 150) { // ~30 segundos
                clearInterval(iInterval);
                that._bInicializandoMapa = false;
                // eslint-disable-next-line no-console
                console.warn("FichaTecnica: contenedor del mapa no disponible tras espera.");
                resolve();
              }
            }, 200);
          }
        });
      }).catch(function (oErr) {
        that._bInicializandoMapa = false;
        // eslint-disable-next-line no-console
        console.error("Error cargando mapa:", oErr);
      });
    },

    _renderizarMapaGoogle: function (google, aViajes) {
      var that = this;
      return new Promise(function (resolve) {
        var oContainer = document.getElementById("fichaMapaRutas");
        if (!oContainer) {
          resolve();
          return;
        }

        if (that._oMapa) {
          oContainer.innerHTML = "";
          that._oMapa = null;
        }

        var oMapa = new google.maps.Map(oContainer, {
          center: { lat: 10.0, lng: -66.0 },
          zoom: 6,
          mapTypeId: "roadmap"
        });
        that._oMapa = oMapa;

        var aColores = ["#0070b1", "#e9730c", "#1b8c1b", "#b00", "#6a0dad", "#d1a006"];
        var oBounds = new google.maps.LatLngBounds();
        var bHayPuntos = false;

        aViajes.forEach(function (oViaje, iIndex) {
          var oRuta = oViaje.ruta || {};
          var aPuntos = oRuta.puntos || [];
          var aPath = [];

          if (Array.isArray(aPuntos) && aPuntos.length > 0) {
            aPath = aPuntos
              .sort(function (a, b) {
                return (a.descripcion || "").localeCompare(b.descripcion || "");
              })
              .map(function (oPunto) {
                return {
                  lat: parseFloat(oPunto.latitud),
                  lng: parseFloat(oPunto.longitud)
                };
              })
              .filter(function (oCoord) {
                return !isNaN(oCoord.lat) && !isNaN(oCoord.lng);
              });
          }

          // Fallback: ruta directa entre origen y destino
          if (aPath.length === 0) {
            var fOrigenLat = parseFloat(oRuta.latitudOrigen || oViaje.origenLatitud);
            var fOrigenLng = parseFloat(oRuta.longitudOrigen || oViaje.origenLongitud);
            var fDestinoLat = parseFloat(oRuta.latitud || oViaje.rutaLatitud);
            var fDestinoLng = parseFloat(oRuta.longitud || oViaje.rutaLongitud);

            if (!isNaN(fOrigenLat) && !isNaN(fOrigenLng) &&
                !isNaN(fDestinoLat) && !isNaN(fDestinoLng)) {
              aPath = [
                { lat: fOrigenLat, lng: fOrigenLng },
                { lat: fDestinoLat, lng: fDestinoLng }
              ];
            }
          }

          if (aPath.length === 0) {
            return;
          }

          bHayPuntos = true;
          aPath.forEach(function (oCoord) {
            oBounds.extend(oCoord);
          });

          var sColor = aColores[iIndex % aColores.length];
          new google.maps.Polyline({
            path: aPath,
            geodesic: true,
            strokeColor: sColor,
            strokeOpacity: 1.0,
            strokeWeight: 3,
            map: oMapa
          });

          new google.maps.Marker({
            position: aPath[0],
            map: oMapa,
            label: "O",
            title: "Origen: " + (oRuta.origen || oViaje.origenRuta || "Inicio")
          });
          new google.maps.Marker({
            position: aPath[aPath.length - 1],
            map: oMapa,
            label: "D",
            title: "Destino: " + (oRuta.destino || oViaje.nombreRuta || "Fin")
          });
        });

        if (bHayPuntos && !oBounds.isEmpty()) {
          oMapa.fitBounds(oBounds);
        }

        resolve();
      });
    },

    _destruirMapa: function () {
      if (this._oMapa) {
        this._oMapa = null;
      }
      var oContainer = document.getElementById("fichaMapaRutas");
      if (oContainer) {
        oContainer.innerHTML = "";
      }
      this._bMapaInicializado = false;
      this._bInicializandoMapa = false;
    }
  });
});
