import { NgZone } from '@angular/core';
import { Observable, Observer, Subscriber, TeardownLogic, PartialObserver, Subscription } from 'rxjs';

export class WebViewObservable<T> extends Observable<T> {
  // zone: NgZone;
  counter = 0;
  operationName: String;

  constructor(operationName: String) {
    super();
    this.operationName = operationName;
  }

  // constructor(zone: NgZone, subscribe?: (this: Observable<T>, subscriber: Subscriber<T>) => TeardownLogic) {
  //   super(subscribe);
  //   this.zone = zone;
  // }

  subscribeZone(zone: NgZone, next: (value: T) => void, error?: (error: any) => void): Subscription {
    let w = window as any;
    let observer :Observer<T> = {
      next:next,
      error:error,
      complete:() => { delete w.he; delete w.obs; },
    };
    return this.subscribe((next) => {}); ///////////// WIP
  }
}
