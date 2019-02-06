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

  ngOnInit() {
    this.infoService.getSQLiteVersion().subscribe(v => {
      this.zone.run(() => { this.sqliteVersion = v; });
    });
  }
}
