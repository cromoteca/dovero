import { Component, NgZone } from '@angular/core';
import { InfoService } from '../services/info.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  constructor(private zone: NgZone, private infoService: InfoService) { }

  display: boolean;

  ngOnInit() {
    this.infoService.getSQLiteVersion().subscribeZone(this.zone, v => console.log("Using SQLite version " + v));
  }

  loadPhotos(map: any) {
    this.infoService.getPhotos().subscribeZone(this.zone, v => {
      console.log(v);
    });
  }
}
