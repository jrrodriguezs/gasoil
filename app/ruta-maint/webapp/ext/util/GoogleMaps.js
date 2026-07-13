sap.ui.define([], function () {
  "use strict";

  var _pLoader = null;
  var _sApiKey = null;
  var _sMapId = null;

  function _loadScript(sUrl) {
    return new Promise(function (resolve, reject) {
      var sCallback = "gmapCbRuta_" + Date.now();
      var oScript = document.createElement("script");

      window[sCallback] = function () {
        resolve();
        try {
          delete window[sCallback];
        } catch (oErr) { // eslint-disable-line no-unused-vars
          window[sCallback] = undefined;
        }
      };

      oScript.src = sUrl + "&callback=" + encodeURIComponent(sCallback);
      oScript.async = true;
      oScript.defer = true;
      oScript.onerror = function () {
        reject(new Error("No se pudo cargar el script de Google Maps."));
      };

      document.head.appendChild(oScript);
    });
  }

  function _fetchConfig(sEndpoint) {
    return fetch("/odata/v4/config/" + sEndpoint, {
      headers: { Accept: "application/json" }
    })
      .then(function (oResponse) {
        if (!oResponse.ok) {
          throw new Error("HTTP " + oResponse.status + " al obtener " + sEndpoint + ".");
        }
        return oResponse.json();
      })
      .then(function (oData) {
        return (oData && oData.value !== undefined ? oData.value : oData) || "";
      });
  }

  return {
    load: function () {
      if (window.google && window.google.maps) {
        return Promise.resolve(window.google);
      }
      if (_pLoader) {
        return _pLoader;
      }

      _pLoader = _fetchConfig("MapsApiKey()")
        .then(function (sKey) {
          if (!sKey) {
            throw new Error("No se configuró GOOGLE_MAPS_API_KEY en el backend.");
          }
          _sApiKey = sKey;
          return _loadScript(
            "https://maps.googleapis.com/maps/api/js?key=" + encodeURIComponent(sKey) +
            "&loading=async&libraries=marker,geometry"
          );
        })
        .then(function () {
          if (!window.google || !window.google.maps) {
            throw new Error("Google Maps no se cargó correctamente.");
          }
          return window.google;
        })
        .catch(function (oErr) {
          _pLoader = null;
          throw oErr;
        });

      return _pLoader;
    },

    getApiKey: function () {
      if (_sApiKey) {
        return Promise.resolve(_sApiKey);
      }
      return _fetchConfig("MapsApiKey()").then(function (sKey) {
        if (!sKey) {
          throw new Error("No se configuró GOOGLE_MAPS_API_KEY en el backend.");
        }
        _sApiKey = sKey;
        return sKey;
      });
    },

    getMapId: function () {
      if (_sMapId) {
        return Promise.resolve(_sMapId);
      }
      return _fetchConfig("MapsMapId()").then(function (sMapId) {
        _sMapId = sMapId;
        return sMapId;
      });
    }
  };
});
