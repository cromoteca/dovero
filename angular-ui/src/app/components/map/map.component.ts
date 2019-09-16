import { Component, OnInit, NgZone } from '@angular/core';
import { map } from 'rxjs/operators';
import { latLng, tileLayer, Map, Control, marker, icon, TooltipEvent, divIcon, Point } from 'leaflet';
import { MarkerClusterGroup } from 'leaflet.markercluster';
import { InfoService } from '../../services/info.service';
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';
import { Observable } from 'rxjs';

//declare var MarkerClusterer: any;

@Component({
  selector: 'app-map',
  templateUrl: './map.component.html',
  styleUrls: ['./map.component.scss']
})
export class MapComponent implements OnInit {

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
        tileLayer('//{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png', { maxZoom: 18, attribution: '...' })
      ],
      zoom: 5,
      center: latLng(47.212834, -1.574735),
      zoomControl: false,
    };

    this.infoService.getPhotos().subscribeZone(this.zone, v => {
      var markers = new MarkerClusterGroup();

      markers.options.iconCreateFunction = function (cluster) {
        return divIcon({ html: '<span class=cluster>' + cluster.getChildCount() + '</span>', iconSize: new Point(25, 25) });
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
          this.infoService.getThumbnail(photo.name).subscribeZone(this.zone, v => {
            e.tooltip.setContent('<img src="data:image/jpeg;base64,' + v + '">');
          });
        });

        layer.bindTooltip(photo.name);
        markers.addLayer(layer);
      });

      this.map.addLayer(markers);
    });
  }

}
