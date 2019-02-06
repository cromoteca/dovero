import { NgZone } from '@angular/core';
import { Observable, Observer, Subscriber, TeardownLogic, PartialObserver, Subscription } from 'rxjs';

export class WebViewObservable<T> extends Observable<T> {
  // zone: NgZone;
  counter = 0;
  operationName: String;

  constructor(operationName?: String) {
    super((observer) => {
      let w = window as any;
      w.he = observer;
      w.obs = observer.next;
      w.external.invoke('window.obs.call(window.he ,"{}"); delete window.obs; delete window.he');
      return { unsubscribe() { } };
    });
    this.operationName = operationName;
  }

  subscribeZone(zone: NgZone, next: (value: T) => void, error?: (error: any) => void): Subscription {
    return this.subscribe((value) => { zone.run(() => next(value)) }, error);
  }
}
