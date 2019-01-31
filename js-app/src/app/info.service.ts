import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class InfoService {

  constructor() { }

  getSQLiteVersionSample(): Observable<String> {
    return of("JS doesn't know!");
  }

  getSQLiteVersion(): Observable<String> {
    return new Observable((observer) => {
      let w = window as any;
      w.he = observer;
      w.obs = observer.next;
      w.external.invoke('window.obs.call(window.he ,"{}");');
      return { unsubscribe() { delete w.he; delete w.obs; } };
    });
  }
}
