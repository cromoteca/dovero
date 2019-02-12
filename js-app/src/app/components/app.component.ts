import { Component, NgZone } from '@angular/core';
import { InfoService } from '../services/info.service';

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
        center: {lat: 47.212834, lng: -1.574735},
        zoom: 12
    };
    this.infoService.getSQLiteVersion().subscribeZone(this.zone, v => this.sqliteVersion = v);
    this.a = Math.random() * 10 | 0;
    this.b = Math.random() * 10 | 0;
    this.infoService.add(this.a, this.b).subscribeZone(this.zone, v => this.sum = v);
  }
}
