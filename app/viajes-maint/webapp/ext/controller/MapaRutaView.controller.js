sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/core/Component",
  "sap/base/security/URLListValidator",
  "viajesmaint/ext/util/GoogleMaps"
], function (
  Controller,
  Component,
  URLListValidator,
  GoogleMaps
) {
  "use strict";

  var MAX_RETRIES = 100;
  var ROUTES_API_URL = "https://routes.googleapis.com/directions/v2:computeRoutes";
  var DEFAULT_ORIGIN = { lat: 10.547027, lng: -71.636306, name: "Maracaibo" };

  function _log(sMsg, oData) {
    // eslint-disable-next-line no-console
    console.log("[MapaRutaView] " + sMsg, oData || "");
  }

  function _warn(sMsg, oData) {
    // eslint-disable-next-line no-console
    console.warn("[MapaRutaView] " + sMsg, oData || "");
  }

  function _error(sMsg, oData) {
    // eslint-disable-next-line no-console
    console.error("[MapaRutaView] " + sMsg, oData || "");
  }

  return Controller.extend("viajesmaint.ext.controller.MapaRutaView", {

    onInit: function () {
      _log("onInit ejecutado");
      this._bMapReady = false;
      this._bInitializing = false;
      this._oMap = null;
      this._oResizeObserver = null;
      this._sCurrentContextPath = null;

      var oView = this.getView();
      if (oView) {
        oView.attachModelContextChange(this._onContextChanged.bind(this));
      }
    },

    onAfterRendering: function () {
      _log("onAfterRendering ejecutado");
      this._tryInit();
    },

    _onContextChanged: function () {
      var oContext = this._findContext();
      var sPath = oContext ? oContext.getPath() : null;
      _log("modelContextChange detectado", sPath);

      if (sPath && sPath === this._sCurrentContextPath) {
        _log("Mismo contexto, se omite reinicialización");
        return;
      }

      this._resetMap();
      this._tryInit();
    },

    _resetMap: function () {
      _log("_resetMap ejecutado");
      this._bMapReady = false;
      this._bInitializing = false;
      if (this._oResizeObserver) {
        this._oResizeObserver.disconnect();
        this._oResizeObserver = null;
      }
      this._oMap = null;
      var oContainer = this._getMapContainer();
      if (oContainer) {
        oContainer.innerHTML = "";
      }
    },

    _tryInit: function () {
      var that = this;
      var iRetries = 0;

      function attempt() {
        if (that._bMapReady || that._bInitializing) {
          return;
        }

        var oContainer = that._getMapContainer();
        if (!oContainer) {
          if (++iRetries <= MAX_RETRIES) {
            setTimeout(attempt, 200);
          } else {
            _warn("No se encontró el contenedor del mapa tras " + MAX_RETRIES + " intentos");
          }
          return;
        }

        _log("Contenedor del mapa encontrado", oContainer);
        that._initMap(oContainer);
      }

      attempt();
    },

    _getMapContainer: function () {
      // El div del mapa se define literalmente en el control HTML con id fijo
      var oMapDiv = document.getElementById("mapa-ruta-container-viajes");
      if (oMapDiv) {
        _log("Contenedor encontrado por ID");
        oMapDiv.style.width = "100%";
        oMapDiv.style.height = "480px";
        oMapDiv.style.minHeight = "480px";
        oMapDiv.style.position = "relative";
        oMapDiv.style.display = "block";
        return oMapDiv;
      }

      // Fallback: obtener el DOM del control HTML
      var oHtml = this.byId("mapaRutaHtml");
      if (oHtml) {
        var oDomRef = oHtml.getDomRef();
        if (oDomRef) {
          _log("Contenedor encontrado por getDomRef del HTML");
          oDomRef.style.width = "100%";
          oDomRef.style.height = "480px";
          oDomRef.style.minHeight = "480px";
          oDomRef.style.position = "relative";
          oDomRef.style.display = "block";
          return oDomRef;
        }
      }

      // Fallback: crear div dinámicamente dentro del VBox
      var oWrapper = this.byId("mapaRutaWrapper");
      if (!oWrapper) {
        _warn("No se encontró el wrapper del mapa");
        return null;
      }

      var oWrapperDom = oWrapper.getDomRef();
      if (!oWrapperDom) {
        _warn("El wrapper del mapa no tiene DOM");
        return null;
      }

      oMapDiv = oWrapperDom.querySelector(".mapa-ruta-mapa");
      if (!oMapDiv) {
        oMapDiv = document.createElement("div");
        oMapDiv.className = "mapa-ruta-mapa";
        oMapDiv.id = "mapa-ruta-container-viajes";
        oMapDiv.style.width = "100%";
        oMapDiv.style.height = "480px";
        oMapDiv.style.minHeight = "480px";
        oMapDiv.style.position = "relative";
        oMapDiv.style.display = "block";
        oWrapperDom.appendChild(oMapDiv);
      }

      return oMapDiv;
    },

    _initMap: function (oContainer) {
      var that = this;

      if (this._bMapReady || this._bInitializing) {
        return;
      }

      var oContext = this._findContext();
      var sPath = oContext ? oContext.getPath() : null;
      if (sPath && sPath === this._sCurrentContextPath) {
        _log("Mismo contexto en _initMap, se omite");
        return;
      }

      this._bInitializing = true;
      _log("Inicializando mapa...");

      this._getTripContext().then(function (oTrip) {
        _log("Contexto del viaje obtenido", oTrip);

        return that._extractPoints(oTrip);
      }).then(function (aPoints) {
        _log("Puntos extraídos", aPoints);

        if (!aPoints || aPoints.length === 0) {
          that._showMessage(oContainer, "No se encontraron coordenadas de origen y destino para este viaje.");
          return;
        }

        if (URLListValidator && typeof URLListValidator.add === "function") {
          URLListValidator.add("https", "maps.googleapis.com", null, null);
          URLListValidator.add("https", "*.google.com", null, null);
          URLListValidator.add("https", "*.gstatic.com", null, null);
        }

        Promise.all([
          GoogleMaps.load(),
          GoogleMaps.getMapId()
        ]).then(function (aResults) {
          var google = aResults[0];
          var sMapId = aResults[1];
          _log("Google Maps cargado correctamente", { google: google, mapId: sMapId });
          if (!sMapId) {
            _warn("No se configuró GOOGLE_MAPS_MAP_ID. Los marcadores avanzados no funcionarán.");
          }
          that._ensureSize(oContainer).then(function () {
            _log("Dimensiones del contenedor listas", {
              width: oContainer.offsetWidth,
              height: oContainer.offsetHeight
            });
            that._renderMap(google, oContainer, aPoints, sMapId);
          });
        }).catch(function (oErr) {
          _error("Error cargando Google Maps", oErr);
          that._showMessage(oContainer, "Error al cargar Google Maps: " + (oErr.message || ""));
        });
      }).catch(function (oErr) {
        _error("Error leyendo contexto del viaje", oErr);
        that._bInitializing = false;
        that._showMessage(oContainer, "Error al leer los datos del viaje.");
      });
    },

    _getTripContext: function () {
      var that = this;

      function requestObject(oContext) {
        if (oContext && typeof oContext.requestObject === "function") {
          return oContext.requestObject();
        }
        return Promise.resolve(oContext ? oContext.getObject() : null);
      }

      function requestEnriched(oContext) {
        var oModel = oContext.getModel ? oContext.getModel() : null;
        var sPath = oContext.getPath ? oContext.getPath() : null;
        if (!oModel || !sPath) {
          return requestObject(oContext);
        }

        // Normalizar a ruta absoluta para bindContext sin contexto padre
        if (sPath.charAt(0) !== "/") {
          sPath = "/" + sPath;
        }

        try {
          var oBinding = oModel.bindContext(sPath, null, {
            $select: "ID,ruta_ID,nombreRuta,origenRuta,origenLatitud,origenLongitud,rutaLatitud,rutaLongitud,latitudOrigen,longitudOrigen,latitudDestino,longitudDestino,destino",
            $expand: "ruta($select=ID,destino,latitud,longitud,latitudOrigen,longitudOrigen,origen)"
          });
          if (oBinding && typeof oBinding.requestObject === "function") {
            return oBinding.requestObject().catch(function (oErr) {
              _warn("No se pudo enriquecer el contexto; usando objeto actual", oErr);
              return requestObject(oContext);
            });
          }
        } catch (oErr) {
          _warn("Error creando binding enriquecido; usando objeto actual", oErr);
        }
        return requestObject(oContext);
      }

      return new Promise(function (resolve) {
        var oContext = that._findContext();
        _log("_findContext resultado", oContext);
        if (oContext) {
          requestEnriched(oContext).then(function (oTrip) {
            _log("requestObject resultado", oTrip);
            resolve(oTrip);
          });
          return;
        }

        var iRetries = 0;
        var iInterval = setInterval(function () {
          oContext = that._findContext();
          if (oContext) {
            clearInterval(iInterval);
            _log("Contexto encontrado tras esperar");
            requestEnriched(oContext).then(resolve);
          } else if (++iRetries >= MAX_RETRIES) {
            clearInterval(iInterval);
            _warn("Contexto no encontrado tras esperar");
            resolve(null);
          }
        }, 200);
      });
    },

    _findContext: function () {
      var oView = this.getView();
      var oContext = oView ? oView.getBindingContext() : null;
      _log("getBindingContext de la vista", oContext);
      if (oContext) {
        return oContext;
      }

      var oOwner = oView ? Component.getOwnerComponentFor(oView) : null;
      _log("Owner component", oOwner);
      if (oOwner) {
        oContext = oOwner.getBindingContext ? oOwner.getBindingContext() : null;
        _log("getBindingContext del owner", oContext);
        if (oContext) {
          return oContext;
        }
        oContext = this._findContextInControl(oOwner.getRootControl ? oOwner.getRootControl() : null);
        if (oContext) {
          return oContext;
        }
      }

      oContext = this._findContextInControl(oView ? oView.getParent() : null);
      if (oContext) {
        return oContext;
      }

      return null;
    },

    _findContextInControl: function (oControl, aVisited) {
      if (!oControl) {
        return null;
      }

      aVisited = aVisited || [];
      if (aVisited.indexOf(oControl) !== -1) {
        return null;
      }
      aVisited.push(oControl);

      var oContext = oControl.getBindingContext ? oControl.getBindingContext() : null;
      if (oContext) {
        return oContext;
      }

      if (oControl.getComponentInstance) {
        try {
          var oComponent = oControl.getComponentInstance();
          if (oComponent) {
            oContext = oComponent.getBindingContext ? oComponent.getBindingContext() : null;
            if (oContext) {
              return oContext;
            }
            oContext = this._findContextInControl(oComponent.getRootControl ? oComponent.getRootControl() : null, aVisited);
            if (oContext) {
              return oContext;
            }
          }
        } catch (oErr) { // eslint-disable-line no-unused-vars
          // ignore
        }
      }

      if (oControl.getParent) {
        oContext = this._findContextInControl(oControl.getParent(), aVisited);
        if (oContext) {
          return oContext;
        }
      }

      return null;
    },

    _extractPoints: function (oTrip) {
      function buildPoint(oTrip, sLatField, sLngField, sNameField, sRutaLatField, sRutaLngField, sRutaNameField, sDefaultName) {
        var fLat = parseFloat(oTrip[sLatField]);
        var fLng = parseFloat(oTrip[sLngField]);
        var sName = oTrip[sNameField] || sDefaultName;

        if ((isNaN(fLat) || isNaN(fLng)) && oTrip.ruta) {
          fLat = parseFloat(oTrip.ruta[sRutaLatField]);
          fLng = parseFloat(oTrip.ruta[sRutaLngField]);
          sName = oTrip.ruta[sRutaNameField] || sName;
        }

        if (isNaN(fLat) || isNaN(fLng)) {
          return null;
        }

        return {
          lat: fLat,
          lng: fLng,
          descripcion: sName
        };
      }

      if (!oTrip) {
        return Promise.resolve([]);
      }

      var aPoints = [];

      var oOrigin = buildPoint(
        oTrip,
        "origenLatitud", "origenLongitud", "origenRuta",
        "latitudOrigen", "longitudOrigen", "origen",
        DEFAULT_ORIGIN.name
      );
      if (oOrigin) {
        aPoints.push(oOrigin);
      }

      var oDestination = buildPoint(
        oTrip,
        "rutaLatitud", "rutaLongitud", "nombreRuta",
        "latitud", "longitud", "destino",
        "Destino"
      );
      if (oDestination) {
        aPoints.push(oDestination);
      }

      return Promise.resolve(aPoints);
    },

    _ensureSize: function (oContainer) {
      return new Promise(function (resolve) {
        function hasSize() {
          return oContainer.offsetWidth > 0 && oContainer.offsetHeight > 0;
        }

        if (hasSize()) {
          resolve();
          return;
        }

        var iRetries = 0;
        var iInterval;

        function forceSize() {
          oContainer.style.width = "100%";
          oContainer.style.height = "480px";
          oContainer.style.minHeight = "430px";
          oContainer.style.position = "relative";
        }

        function ready() {
          clearInterval(iInterval);
          if (!hasSize()) {
            forceSize();
          }
          resolve();
        }

        if (typeof window.ResizeObserver !== "undefined") {
          var oObserver = new window.ResizeObserver(function (aEntries) {
            var oEntry = aEntries[0];
            if (oEntry && oEntry.contentRect && oEntry.contentRect.width > 0 && oEntry.contentRect.height > 0) {
              oObserver.disconnect();
              ready();
            }
          });
          oObserver.observe(oContainer);

          iInterval = setInterval(function () {
            if (hasSize()) {
              oObserver.disconnect();
              ready();
            } else if (++iRetries >= MAX_RETRIES) {
              oObserver.disconnect();
              ready();
            }
          }, 200);
        } else {
          iInterval = setInterval(function () {
            if (hasSize()) {
              ready();
            } else if (++iRetries >= MAX_RETRIES) {
              ready();
            }
          }, 200);
        }
      });
    },

    _renderMap: function (google, oContainer, aPoints, sMapId) {
      var that = this;
      var oContext = this._findContext();
      this._sCurrentContextPath = oContext ? oContext.getPath() : null;
      _log("_renderMap ejecutado", { path: this._sCurrentContextPath, points: aPoints, mapId: sMapId });

      if (this._oMap) {
        oContainer.innerHTML = "";
        this._oMap = null;
      }

      oContainer.style.width = "100%";
      oContainer.style.height = "480px";
      oContainer.style.minHeight = "430px";
      oContainer.style.position = "relative";

      var oMapOptions = {
        center: aPoints[0],
        zoom: 7,
        mapTypeId: "roadmap"
      };
      if (sMapId) {
        oMapOptions.mapId = sMapId;
      }
      var oMap = new google.maps.Map(oContainer, oMapOptions);
      this._oMap = oMap;
      this._bMapReady = true;
      this._bInitializing = false;

      _log("Mapa de Google creado", oMap);

      setTimeout(function () {
        if (oMap && google && google.maps && google.maps.event) {
          google.maps.event.trigger(oMap, "resize");
        }
      }, 300);

      this._attachResizeListener(oContainer);

      // Dibujar marcadores para origen y destino
      aPoints.forEach(function (oPoint, iIndex) {
        var sLabel = iIndex === 0 ? "O" : "D";
        var sColor = iIndex === 0 ? "#0070b1" : "#107e3e";
        new google.maps.marker.AdvancedMarkerElement({
          map: oMap,
          position: oPoint,
          title: oPoint.descripcion,
          content: that._createMarkerContent(sLabel, sColor)
        });
      });

      // Si solo hay un punto, no dibujar ruta
      if (aPoints.length < 2) {
        return;
      }

      // Intentar obtener ruta real via Routes API
      this._computeRoute(google, aPoints).then(function (aPath) {
        _log("Ruta calculada, puntos de polilínea", aPath.length);
        new google.maps.Polyline({
          path: aPath,
          geodesic: true,
          strokeColor: "#0070b1",
          strokeOpacity: 1.0,
          strokeWeight: 4,
          map: oMap
        });
        that._fitBounds(google, oMap, aPath);
      }).catch(function (oErr) {
        _warn("Routes API falló, usando fallback a líneas rectas", oErr);
        that._drawFallbackRoute(google, oMap, aPoints);
      });
    },

    _computeRoute: function (google, aPoints) {
      return GoogleMaps.getApiKey().then(function (sApiKey) {
        var oOrigin = {
          location: {
            latLng: { latitude: aPoints[0].lat, longitude: aPoints[0].lng }
          }
        };

        var oDestination = {
          location: {
            latLng: { latitude: aPoints[aPoints.length - 1].lat, longitude: aPoints[aPoints.length - 1].lng }
          }
        };

        var aIntermediates = [];
        if (aPoints.length > 2) {
          for (var i = 1; i < aPoints.length - 1; i++) {
            aIntermediates.push({
              location: {
                latLng: { latitude: aPoints[i].lat, longitude: aPoints[i].lng }
              }
            });
          }
        }

        var oBody = {
          origin: oOrigin,
          destination: oDestination,
          travelMode: "DRIVE",
          routingPreference: "TRAFFIC_AWARE",
          polylineEncoding: "ENCODED_POLYLINE",
          computeAlternativeRoutes: false,
          optimizeWaypointOrder: false,
          routeModifiers: {
            avoidTolls: false,
            avoidHighways: false,
            avoidFerries: false
          }
        };

        if (aIntermediates.length > 0) {
          oBody.intermediates = aIntermediates;
        }

        _log("Request a Routes API", oBody);

        return fetch(ROUTES_API_URL, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-Goog-Api-Key": sApiKey,
            "X-Goog-FieldMask": "routes.polyline.encodedPolyline"
          },
          body: JSON.stringify(oBody)
        });
      }).then(function (oResponse) {
        if (!oResponse.ok) {
          return oResponse.text().then(function (sText) {
            throw new Error("Routes API HTTP " + oResponse.status + ": " + sText);
          });
        }
        return oResponse.json();
      }).then(function (oData) {
        if (!oData.routes || oData.routes.length === 0) {
          throw new Error("Routes API no devolvió rutas.");
        }

        var sEncodedPolyline = oData.routes[0].polyline.encodedPolyline;
        if (!sEncodedPolyline) {
          throw new Error("Routes API no devolvió polilínea.");
        }

        var aPath = google.maps.geometry.encoding.decodePath(sEncodedPolyline);
        if (!aPath || aPath.length === 0) {
          throw new Error("No se pudo decodificar la polilínea.");
        }

        return aPath;
      });
    },

    _drawFallbackRoute: function (google, oMap, aPoints) {
      _log("Dibujando ruta fallback");
      new google.maps.Polyline({
        path: aPoints,
        geodesic: true,
        strokeColor: "#0070b1",
        strokeOpacity: 1.0,
        strokeWeight: 3,
        map: oMap
      });
      this._fitBounds(google, oMap, aPoints);
    },

    _fitBounds: function (google, oMap, aPath) {
      var oBounds = new google.maps.LatLngBounds();
      aPath.forEach(function (oPoint) {
        oBounds.extend(oPoint);
      });
      oMap.fitBounds(oBounds);
    },

    _createMarkerContent: function (sLabel, sColor) {
      var oDiv = document.createElement("div");
      oDiv.style.backgroundColor = sColor || "#0070b1";
      oDiv.style.color = "#fff";
      oDiv.style.borderRadius = "50%";
      oDiv.style.width = "26px";
      oDiv.style.height = "26px";
      oDiv.style.display = "flex";
      oDiv.style.alignItems = "center";
      oDiv.style.justifyContent = "center";
      oDiv.style.fontWeight = "bold";
      oDiv.style.fontSize = "13px";
      oDiv.style.border = "2px solid #fff";
      oDiv.style.boxShadow = "0 1px 4px rgba(0,0,0,0.4)";
      oDiv.textContent = sLabel;
      return oDiv;
    },

    _attachResizeListener: function (oContainer) {
      if (typeof window.ResizeObserver === "undefined") {
        return;
      }

      var that = this;
      this._oResizeObserver = new window.ResizeObserver(function (aEntries) {
        var oEntry = aEntries[0];
        if (oEntry && oEntry.contentRect && oEntry.contentRect.width > 0 && oEntry.contentRect.height > 0) {
          if (that._oMap && window.google && window.google.maps && window.google.maps.event) {
            window.google.maps.event.trigger(that._oMap, "resize");
          }
        }
      });
      this._oResizeObserver.observe(oContainer);
    },

    _showMessage: function (oContainer, sMessage) {
      _log("Mostrando mensaje", sMessage);
      oContainer.innerHTML = "";
      oContainer.style.display = "flex";
      oContainer.style.alignItems = "center";
      oContainer.style.justifyContent = "center";
      oContainer.style.backgroundColor = "#f7f7f7";
      oContainer.style.color = "#666";
      oContainer.style.padding = "1rem";
      oContainer.style.textAlign = "center";
      oContainer.textContent = sMessage;
      this._bInitializing = false;
    },

    onExit: function () {
      _log("onExit ejecutado");
      if (this._oResizeObserver) {
        this._oResizeObserver.disconnect();
        this._oResizeObserver = null;
      }
      this._oMap = null;
      var oContainer = this._getMapContainer();
      if (oContainer) {
        oContainer.innerHTML = "";
      }
      this._bMapReady = false;
      this._bInitializing = false;
    }
  });
});
