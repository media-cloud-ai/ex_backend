import { Injectable } from '@angular/core'
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, map, tap } from 'rxjs/operators'

import {UserPage, RolePage, RightDefinitionsPage} from '../models/page/user_page'
import {User, Confirm, Role, ValidationLink} from '../models/user'
import {AuthService} from '../authentication/auth.service'

@Injectable()
export class UserService {
  private usersUrl = '/api/users'
  private rolesUrl = '/api/step_flow/roles'
  private rightDefinitionsUrl = '/api/step_flow/right_definitions'

  constructor(private http: HttpClient) { }

  getUsers(page: number, per_page: number): Observable<UserPage> {
    let params = new HttpParams()
    params = params.append('size', per_page.toString())
    if (page > 0) {
      params = params.append('page', String(page))
    }

    return this.http.get<UserPage>(this.usersUrl, {params: params})
      .pipe(
        tap(userPage => this.log('fetched UserPage')),
        catchError(this.handleError('getUsers', undefined))
      )
  }

  getUserByUuid(uuid: string): Observable<any> {
    return this.http.get<User>(this.usersUrl + "/search/" + uuid)
      .pipe(
        tap(userPage => this.log('fetched User')),
        catchError(this.handleError('getUserByUuid', undefined))
      )
  }

  inviteUser(email: string): Observable<User> {
    let params = {
      user: {
        email: email
      }
    }
    return this.http.post<User>(this.usersUrl, params)
      .pipe(
        tap(userPage => this.log('invite User')),
        catchError(this.handleError('inviteUser', undefined))
      )
  }

  generateValidationLink(user: User): Observable<ValidationLink> {
    let params = new HttpParams()
    params = params.append('id', user.id.toString())
    return this.http.post<User>(this.usersUrl + '/generate_validation_link', params)
      .pipe(
        tap(userPage => this.log('Generate validation link')),
        catchError(this.handleError('generateValidationLink', undefined))
      )
    }

  generateCredentials(user: User): Observable<User> {
    let params = new HttpParams()
    params = params.append('id', user.id.toString())

    return this.http.post<User>(this.usersUrl + '/generate_credentials', params)
      .pipe(
        tap(userPage => this.log('Generate credentials')),
        catchError(this.handleError('generateCredentials', undefined))
      )
  }

  removeUser(user_id: number): Observable<User> {
    return this.http.delete<User>(this.usersUrl + '/' + user_id)
      .pipe(
        tap(userPage => this.log('remove User')),
        catchError(this.handleError('removeUser', undefined))
      )
  }

  confirm(password: string, key: string): Observable<Confirm> {
    let params = new HttpParams()
    params = params.append('password', password)
    params = params.append('key', key)

    return this.http.get<Confirm>('/validate', {params: params})
      .pipe(
        tap(user => this.log('fetched Confirm User')),
        catchError(this.handleError('confirm', undefined))
      )
  }

  updateRoles(user_id: number, roles: string[]) {
    let params = {
      user: {
        roles: roles
      }
    }
    return this.http.put<User>(this.usersUrl + '/' + user_id, params)
      .pipe(
        tap(userPage => this.log('update Roles')),
        catchError(this.handleError('updateRoles', undefined))
      )
  }

  getRoles(page: number, per_page: number): Observable<RolePage> {
    let params = new HttpParams()
    params = params.append('size', per_page.toString())
    if (page > 0) {
      params = params.append('page', String(page))
    }

    return this.http.get<RolePage>(this.rolesUrl, {params: params})
      .pipe(
        tap(rolePage => this.log('fetched RolePage')),
        catchError(this.handleError('getRoles', undefined))
      )
  }

  getAllRoles(): Observable<RolePage> {
    return this.http.get<RolePage>(this.rolesUrl)
      .pipe(
        tap(rolePage => this.log('fetched All Roles')),
        catchError(this.handleError('getRoles', undefined))
      )
  }

  getRightDefinitions(): Observable<RightDefinitionsPage> {
    let params = new HttpParams()
    return this.http.get<RightDefinitionsPage>(this.rightDefinitionsUrl, {params: params})
      .pipe(
        tap(rightDefinitionsPage => this.log('fetched RightDefinitionsPage')),
        catchError(this.handleError('getRightDefinitions', undefined))
      )
  }

  createRole(role: Role): Observable<Role> {
    return this.http.post<Role>(this.rolesUrl, role)
      .pipe(
        tap(role => this.log('create Role')),
        catchError(this.handleError('createRole', undefined))
      )
  }

  updateRole(role: Role): Observable<Role> {
    return this.http.put<Role>(this.rolesUrl + '/' + role.id, role)
      .pipe(
        tap(role => this.log('update Role')),
        catchError(this.handleError('updateRole', undefined))
      )
  }

  deleteRole(role: Role): Observable<Role> {
    return this.http.delete<Role>(this.rolesUrl + '/' + role.id)
      .pipe(
        tap(role => this.log('delete Role')),
        catchError(this.handleError('deleteRole', undefined))
      )
  }

  deleteUsersRole(role: Role): Observable<any> {
    return this.http.delete<any>(this.usersUrl + '/roles/' + role.name)
      .pipe(
        tap(userEmails => this.log('delete Users Role')),
        catchError(this.handleError('deleteUsersRole', undefined))
      )
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('UserService: ' + message)
  }
}
