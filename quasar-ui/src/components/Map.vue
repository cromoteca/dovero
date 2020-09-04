<template>
  <l-map :zoom="zoom" :center="center" :options="mapOptions" style="min-height: inherit">
    <l-tile-layer :url="url" :attribution="attribution" />
    <l-marker :lat-lng="withPopup">
      <l-popup>
        <div @click="innerClick">
          I am a popup
          <p v-show="showParagraph">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque
            sed pretium nisl, ut sagittis sapien. Sed vel sollicitudin nisi.
            Donec finibus semper metus id malesuada.
          </p>
        </div>
      </l-popup>
    </l-marker>
    <l-marker :lat-lng="withTooltip">
      <l-tooltip :options="{ permanent: true, interactive: true }">
        <div @click="innerClick">
          I am a tooltip
          <p v-show="showParagraph">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque
            sed pretium nisl, ut sagittis sapien. Sed vel sollicitudin nisi.
            Donec finibus semper metus id malesuada.
          </p>
        </div>
      </l-tooltip>
    </l-marker>
  </l-map>
</template>

<script>
import L from 'leaflet'
import { LMap, LTileLayer, LMarker, LPopup, LTooltip } from 'vue2-leaflet'

delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
  iconUrl: require('leaflet/dist/images/marker-icon.png'),
  shadowUrl: require('leaflet/dist/images/marker-shadow.png')
})

export default {
  name: 'Map',
  components: {
    LMap,
    LTileLayer,
    LMarker,
    LPopup,
    LTooltip
  },
  data () {
    return {
      zoom: 13,
      center: L.latLng(47.41322, -1.219482),
      url: '//{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
      attribution:
        '&copy; <a href="//osm.org/copyright">OpenStreetMap</a> contributors',
      withPopup: L.latLng(47.41322, -1.219482),
      withTooltip: L.latLng(47.41422, -1.250482),
      currentZoom: 11.5,
      currentCenter: L.latLng(47.41322, -1.219482),
      showParagraph: false,
      mapOptions: {
        zoomSnap: 0.5
      }
    }
  }
}
</script>
