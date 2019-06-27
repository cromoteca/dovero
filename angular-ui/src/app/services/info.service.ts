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
    return new WebViewObservable({
      cmd: 'getSQLiteVersion',
    });
  }

  add(a: number, b: number): WebViewObservable<number> {
    return new WebViewObservable({
      cmd: 'add',
      a: a,
      b: b,
    });
  }

  getPhotos(): WebViewObservable<any>{
    return new WebViewObservable({
      cmd: 'getPhotos',
    });
  }

  getThumbnail(name: String) {
    return new WebViewObservable({
      cmd: 'getThumbnail',
      name: name,
    });
  }
}
