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

  sqliteVersion: String;
  a: number;
  b: number;
  sum: number;
  options: any;
  display: boolean;

  ngOnInit() {
    this.options = {
      layers: [
        tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 18, attribution: '...' })
      ],
      zoom: 5,
      center: latLng(47.212834, -1.574735)
    };
    this.infoService.getSQLiteVersion().subscribeZone(this.zone, v => this.sqliteVersion = v);
    this.a = Math.random() * 10 | 0;
    this.b = Math.random() * 10 | 0;
    this.infoService.add(this.a, this.b).subscribeZone(this.zone, v => this.sum = v);
    this.infoService.getPhotos().subscribeZone(this.zone, v => console.log("LE FOTO!!! " + v));
  }

  loadPhotos(map: any) {
    this.infoService.getPhotos().subscribeZone(this.zone, v => {
      console.log(v);
    });
  }
}
