import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { catchError, tap } from 'rxjs/operators';

import {QueuePage} from '../models/page/queue_page';

@Injectable()
export class AmqpService {
  private queuesUrl = 'api/amqp/queues';

  constructor(private http: HttpClient) { }

  getQueues(): Observable<QueuePage> {
    return this.http.get<QueuePage>(this.queuesUrl)
      .pipe(
        tap(queuepage => this.log('fetched QueuePage')),
        catchError(this.handleError('getQueues', undefined))
      );
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`);
      return of(result as T);
    };
  }

  private log(message: string) {
    console.log('AmqpService: ' + message);
  }
}
