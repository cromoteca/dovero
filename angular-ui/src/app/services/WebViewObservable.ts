import { NgZone } from '@angular/core';
import { Observable, Observer, Subscriber, TeardownLogic, PartialObserver, Subscription } from 'rxjs';

export class WebViewObservable<T> extends Observable<T> {
  // zone: NgZone;
  counter = 0;

  constructor(command: any) {
    super((observer) => {
      let w = window as any;
      let id = 'id' + String(Math.random()).substring(2);

      w[id] = {
        fn: result => observer.next(result),
        ctx: observer
      }

      let payload: any = {
        id: id,
        command: command
      }

      w.external.invoke(JSON.stringify(payload));
      return { unsubscribe() { } };
    });
  }

  subscribeZone(zone: NgZone, next: (value: T) => void, error?: (error: any) => void): Subscription {
    return this.subscribe((value) => { zone.run(() => next(value)) }, error);
  }
}
