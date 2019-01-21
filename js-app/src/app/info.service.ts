import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class InfoService {

  constructor() { }

  getSQLiteVersion(): Observable<String> {
    return of("JS doesn't know!");
  }
}
