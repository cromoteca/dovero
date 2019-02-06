import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { WebViewObservable } from './WebViewObservable';

@Injectable({
  providedIn: 'root'
})
export class InfoService {

  constructor() { }

  getSQLiteVersionSample(): Observable<String> {
    return of("JS doesn't know!");
  }

  getSQLiteVersion(): WebViewObservable<String> {
    return new WebViewObservable();
  }
}
