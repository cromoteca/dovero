import { Component, NgZone } from '@angular/core';
import { InfoService } from '../services/info.service';
import { latLng, tileLayer } from 'leaflet';

declare var MarkerClusterer: any;

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  constructor(private zone: NgZone, private infoService: InfoService) { }

  options: any;
  display: boolean;

  ngOnInit() {
    this.infoService.getSQLiteVersion().subscribeZone(this.zone, v => console.log("Using SQLite version " + v));
    this.options = {
      layers: [
        tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 18, attribution: '...' })
      ],
      zoom: 5,
      center: latLng(47.212834, -1.574735)
    };
  }

  loadPhotos(map: any) {
    this.infoService.getPhotos().subscribeZone(this.zone, v => {
      console.log(v);
    });
  }
}
