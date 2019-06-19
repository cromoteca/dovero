import { Component, NgZone } from '@angular/core';
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { latLng, tileLayer, Map, Control, marker, icon, TooltipEvent, divIcon } from 'leaflet';
import { MarkerClusterGroup } from 'leaflet.markercluster';
import { InfoService } from '../services/info.service';

//declare var MarkerClusterer: any;

@Component({
  selector: 'app-nav',
  templateUrl: './nav.component.html',
  styleUrls: ['./nav.component.scss']
})
export class NavComponent {

  map: Map;

  mapOptions: any;

  isHandset$: Observable<boolean> = this.breakpointObserver.observe(Breakpoints.Handset)
    .pipe(
      map(result => result.matches)
    );

  constructor(private zone: NgZone, private infoService: InfoService, private breakpointObserver: BreakpointObserver) { }

  onMapReady(map: Map) {
    this.map = map;
    new Control.Zoom({ position: 'bottomleft' }).addTo(map);
  }

  ngOnInit() {
    this.mapOptions = {
      layers: [
        tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 18, attribution: '...' })
      ],
      zoom: 5,
      center: latLng(47.212834, -1.574735),
      zoomControl: false,
    };

    this.infoService.getPhotos().subscribeZone(this.zone, v => {
      var markers = new MarkerClusterGroup();

      markers.options.iconCreateFunction = function(cluster) {
        return divIcon({ html: '<b>' + cluster.getChildCount() + '</b>' });
      };

      v.forEach(photo => {
        let layer = marker([photo.lat, photo.lon], {
          icon: icon({
            iconSize: [25, 41],
            iconAnchor: [13, 41],
            iconUrl: 'assets/marker-icon.png',
            shadowUrl: 'assets/marker-shadow.png'
          })
        });

        layer.addEventListener('tooltipopen', (e: TooltipEvent) => {
          e.tooltip.setContent(photo.name);
        });

        layer.bindTooltip(photo.name);
        markers.addLayer(layer);
      });

      this.map.addLayer(markers);
    });
  }

}
