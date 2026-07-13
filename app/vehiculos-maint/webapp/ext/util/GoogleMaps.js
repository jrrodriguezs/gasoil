sap.ui.define([], function () {
  "use strict";

  var _pGoogle = null;

  function _cargarScript(sUrl) {
    return new Promise(function (resolve, reject) {
      var sCallback = "googleMapsCallback_" + Date.now();
      var sUrlConCallback = sUrl + "&callback=" + encodeURIComponent(sCallback);

      window[sCallback] = function () {
        resolve();
        try {
          delete window[sCallback];
        } catch (e) { // eslint-disable-line no-unused-vars
          window[sCallback] = undefined;
        }
      };

      var oScript = document.createElement("script");
      oScript.src = sUrlConCallback;
      oScript.async = true;
      oScript.defer = true;
      oScript.onerror = function () {
        reject(new Error("No se pudo cargar el script de Google Maps."));
      };
      document.head.appendChild(oScript);
    });
  }

  return {
    cargar: function () {
      if (_pGoogle) {
        return _pGoogle;
      }
      if (window.google && window.google.maps) {
        return Promise.resolve(window.google);
      }

      _pGoogle = fetch("/odata/v4/config/MapsApiKey()", {
        headers: { Accept: "application/json" }
      })
        .then(function (oResponse) {
          if (!oResponse.ok) {
            throw new Error("HTTP " + oResponse.status + " al obtener la API key de Google Maps.");
          }
          return oResponse.json();
        })
        .then(function (oData) {
          var sKey = (oData.value !== undefined ? oData.value : oData) || "";
          if (!sKey) {
            throw new Error("No se configuró GOOGLE_MAPS_API_KEY en el backend.");
          }
          var sUrl = "https://maps.googleapis.com/maps/api/js?key=" + encodeURIComponent(sKey) + "&loading=async";
          return _cargarScript(sUrl);
        })
        .then(function () {
          if (!window.google || !window.google.maps) {
            throw new Error("Google Maps no se expuso en window.google tras cargar el script.");
          }
          return window.google;
        });

      return _pGoogle;
    }
  };
});
