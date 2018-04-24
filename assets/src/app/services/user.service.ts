import { Injectable } from '@angular/core';
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { catchError, map, tap } from 'rxjs/operators';

import {UserPage} from '../models/page/user_page';
import {User, Confirm} from '../models/user';

@Injectable()
export class UserService {
  private usersUrl = 'api/users';

  constructor(private http: HttpClient) { }

  getUsers(page: number, per_page: number): Observable<UserPage> {
    let params = new HttpParams();
    params = params.append('per_page', per_page.toString());
    if(page > 0) {
      params = params.append('page', String(page + 1));
    }

    return this.http.get<UserPage>(this.usersUrl, {params: params})
      .pipe(
        tap(userPage => this.log('fetched UserPage')),
        catchError(this.handleError('getUsers', undefined))
      );
  }

  createUser(email: string, password: string): Observable<User> {
    let params = {
      user:{
        email: email,
        password: password
      }
    };
    return this.http.post<User>(this.usersUrl, params)
      .pipe(
        tap(userPage => this.log('create User')),
        catchError(this.handleError('createUser', undefined))
      );
  }

  removeUser(user_id: number): Observable<User> {
    return this.http.delete<User>(this.usersUrl + "/" + user_id)
      .pipe(
        tap(userPage => this.log('remove User')),
        catchError(this.handleError('removeUser', undefined))
      );
  }

  confirm(key: string): Observable<Confirm> {
    let params = new HttpParams();
    params = params.append('key', key);

    return this.http.get<Confirm>("/api/confirm", {params: params})
      .pipe(
        tap(user => this.log('fetched Confirm User')),
        catchError(this.handleError('confirm', undefined))
      );
  }

  updateRights(user_id: number, rights: any) {
    let params = {
      user: {
        rights: rights
      }
    }
    return this.http.put<User>(this.usersUrl + "/" + user_id, params)
      .pipe(
        tap(userPage => this.log('update Rights')),
        catchError(this.handleError('updateRights', undefined))
      );
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`);
      return of(result as T);
    };
  }

  private log(message: string) {
    console.log('UserService: ' + message);
  }
}
