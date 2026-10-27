/*global L*/
// Leaflet map helpers replacing gmaps4rails.
window.AdgbMap = {
  // Esri World Imagery approximates the previous Google satellite basemap (no API key).
  satelliteLayer: function () {
    return L.tileLayer(
      "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
      {
        attribution:
          "Tiles &copy; Esri — Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community",
        maxZoom: 19
      }
    );
  },

  markerFor: function (data) {
    var color = data.precise ? "#d9534f" : "#337ab7";
    var marker = L.circleMarker([data.lat, data.lng], {
      radius: 8,
      color: "#ffffff",
      weight: 1,
      fillColor: color,
      fillOpacity: 0.9
    });
    var popup = data.popup || data.infowindow;
    if (popup) {
      marker.bindPopup(popup);
    }
    return marker;
  },

  /**
   * @param {string} elementId DOM id of the map container
   * @param {Array} markers [{lat, lng, popup|infowindow, precise}]
   * @param {Object} [options] { cluster: true|false, singleZoom: number }
   */
  build: function (elementId, markers, options) {
    options = options || {};
    var el = document.getElementById(elementId);
    if (!el || typeof L === "undefined") {
      return null;
    }

    // Destroy any previous map instance on this container (modal reloads).
    if (el._leaflet_id) {
      el._leaflet_id = null;
      el.innerHTML = "";
    }

    var map = L.map(el, { scrollWheelZoom: false });
    this.satelliteLayer().addTo(map);

    var points = (markers || []).filter(function (m) {
      return m && m.lat != null && m.lng != null;
    });

    var layerGroup =
      options.cluster === false || typeof L.markerClusterGroup !== "function"
        ? L.layerGroup()
        : L.markerClusterGroup({
            maxClusterRadius: 40,
            showCoverageOnHover: false
          });

    var latLngs = [];
    points.forEach(function (data) {
      var marker = AdgbMap.markerFor(data);
      layerGroup.addLayer(marker);
      latLngs.push([data.lat, data.lng]);
    });
    map.addLayer(layerGroup);

    if (latLngs.length === 1) {
      map.setView(latLngs[0], options.singleZoom || 16);
    } else if (latLngs.length > 1) {
      map.fitBounds(latLngs, { padding: [36, 36], maxZoom: 18 });
    } else {
      // Babylon / default Babylon findspot area
      map.setView([32.542, 44.421], 13);
    }

    // Bootstrap modals / late layout: Leaflet needs a size refresh.
    var refresh = function () {
      map.invalidateSize();
    };
    setTimeout(refresh, 250);
    if (window.jQuery) {
      jQuery(el).closest(".modal").one("shown.bs.modal", refresh);
    }

    return map;
  }
};
