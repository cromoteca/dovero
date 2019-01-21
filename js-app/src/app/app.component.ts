import { Component } from '@angular/core';
import { InfoService } from './info.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  constructor(private infoService: InfoService) { }

  sqliteVersion: String;

  ngOnInit() {
    this.infoService.getSQLiteVersion().subscribe(v => this.sqliteVersion = v);
  }
}
