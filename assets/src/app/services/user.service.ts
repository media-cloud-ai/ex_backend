import { Injectable } from '@angular/core'
import { HttpClient, HttpParams } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'

import {
  UserPage,
  RolePage,
  RightDefinitionsPage,
} from '../models/page/user_page'
import { User, Confirm, Role, ValidationLink, Info } from '../models/user'
import { WorkflowQueryParams } from '../models/page/workflow_page'

@Injectable()
export class UserService {
  private usersUrl = '/api/users'
  private rolesUrl = '/api/step_flow/roles'
  private rightDefinitionsUrl = '/api/step_flow/right_definitions'

  constructor(private http: HttpClient) {}

  getUsers(page: number, per_page: number): Observable<UserPage> {
    let params = new HttpParams()
    params = params.append('size', per_page.toString())
    if (page > 0) {
      params = params.append('page', String(page))
    }

    return this.http.get<UserPage>(this.usersUrl, { params: params }).pipe(
      tap((_userPage) => this.log('fetched UserPage')),
      catchError(this.handleError('getUsers', undefined)),
    )
  }

  getUserByUuid(uuid: string): Observable<any> {
    return this.http.get<User>(this.usersUrl + '/search/' + uuid).pipe(
      tap((_userPage) => this.log('fetched User')),
      catchError(this.handleError('getUserByUuid', undefined)),
    )
  }

  inviteUser(
    email: string,
    first_name: string,
    last_name: string,
  ): Observable<User> {
    const params = {
      user: {
        email: email,
        first_name: first_name,
        last_name: last_name,
      },
    }

    return this.http.post<User>(this.usersUrl, params).pipe(
      tap((_userPage) => this.log('invite User')),
      catchError(this.handleError('inviteUser', undefined)),
    )
  }

  updateUser(
    id: number,
    first_name: string,
    last_name: string,
  ): Observable<User> {
    const params = {
      id: id,
      user: {
        first_name: first_name,
        last_name: last_name,
      },
    }

    return this.http.put<User>(this.usersUrl + '/' + id, params).pipe(
      tap((_userPage) => this.log('update User')),
      catchError(this.handleError('updateUser', undefined)),
    )
  }

  generateValidationLink(user: User): Observable<ValidationLink> {
    let params = new HttpParams()
    params = params.append('id', user.id.toString())
    return this.http
      .post<User>(this.usersUrl + '/generate_validation_link', params)
      .pipe(
        tap((_userPage) => this.log('Generate validation link')),
        catchError(this.handleError('generateValidationLink', undefined)),
      )
  }

  generateCredentials(user: User): Observable<User> {
    let params = new HttpParams()
    params = params.append('id', user.id.toString())

    return this.http
      .post<User>(this.usersUrl + '/generate_credentials', params)
      .pipe(
        tap((_userPage) => this.log('Generate credentials')),
        catchError(this.handleError('generateCredentials', undefined)),
      )
  }

  removeUser(user_id: number): Observable<User> {
    return this.http.delete<User>(this.usersUrl + '/' + user_id).pipe(
      tap((_userPage) => this.log('remove User')),
      catchError(this.handleError('removeUser', undefined)),
    )
  }

  confirm(password: string, key: string): Observable<Confirm> {
    let params = new HttpParams()
    params = params.append('password', password)
    params = params.append('key', key)

    return this.http.get<Confirm>('/validate', { params: params }).pipe(
      tap((_user) => this.log('fetched Confirm User')),
      catchError(this.handleError('confirm', undefined)),
    )
  }

  updateRoles(user_id: number, roles: string[]) {
    const params = {
      user: {
        roles: roles,
      },
    }
    return this.http.put<User>(this.usersUrl + '/' + user_id, params).pipe(
      tap((_userPage) => this.log('update Roles')),
      catchError(this.handleError('updateRoles', undefined)),
    )
  }

  getRoles(page: number, per_page: number): Observable<RolePage> {
    let params = new HttpParams()
    params = params.append('size', per_page.toString())
    if (page > 0) {
      params = params.append('page', String(page))
    }

    return this.http.get<RolePage>(this.rolesUrl, { params: params }).pipe(
      tap((_rolePage) => this.log('fetched RolePage')),
      catchError(this.handleError('getRoles', undefined)),
    )
  }

  getAllRoles(): Observable<RolePage> {
    return this.http.get<RolePage>(this.rolesUrl).pipe(
      tap((_rolePage) => this.log('fetched All Roles')),
      catchError(this.handleError('getRoles', undefined)),
    )
  }

  getRightDefinitions(): Observable<RightDefinitionsPage> {
    const params = new HttpParams()
    return this.http
      .get<RightDefinitionsPage>(this.rightDefinitionsUrl, { params: params })
      .pipe(
        tap((_rightDefinitionsPage) =>
          this.log('fetched RightDefinitionsPage'),
        ),
        catchError(this.handleError('getRightDefinitions', undefined)),
      )
  }

  createRole(role: Role): Observable<Role> {
    return this.http.post<Role>(this.rolesUrl, role).pipe(
      tap((_role) => this.log('create Role')),
      catchError(this.handleError('createRole', undefined)),
    )
  }

  updateRole(role: Role): Observable<Role> {
    return this.http.put<Role>(this.rolesUrl + '/' + role.id, role).pipe(
      tap((_role) => this.log('update Role')),
      catchError(this.handleError('updateRole', undefined)),
    )
  }

  deleteRole(role: Role): Observable<Role> {
    return this.http.delete<Role>(this.rolesUrl + '/' + role.id).pipe(
      tap((_role) => this.log('delete Role')),
      catchError(this.handleError('deleteRole', undefined)),
    )
  }

  deleteUsersRole(role: Role): Observable<any> {
    return this.http.delete<any>(this.usersUrl + '/roles/' + role.name).pipe(
      tap((_userEmails) => this.log('delete Users Role')),
      catchError(this.handleError('deleteUsersRole', undefined)),
    )
  }

  getWorkflowFilters(): Observable<any> {
    return this.http
      .get<Array<string>>(this.usersUrl + '/filters/workflow')
      .pipe(
        tap((_workflowPage) => this.log('fetched Workflow filters')),
        catchError(this.handleError('getWorkflowStatus', undefined)),
      )
  }

  saveWorkflowFilters(
    filter_name: string,
    filters: WorkflowQueryParams,
  ): Observable<Info> {
    const params = {
      filter_name: filter_name,
      filters: filters,
    }

    return this.http
      .post<Info>(this.usersUrl + '/filters/workflow', params)
      .pipe(
        tap((_workflowPage) => this.log('save User workflow filters')),
        catchError(this.handleError('saveWorkflowFilters', undefined)),
      )
  }

  deleteFilter(filter_id: number): Observable<any> {
    return this.http
      .delete<WorkflowQueryParams>(
        this.usersUrl + '/filters/workflow/' + filter_id,
      )
      .pipe(
        tap((_workflowPage) => this.log('delete User workflow filters')),
        catchError(this.handleError('deleteWorkflowFilters', undefined)),
      )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('UserService: ' + message)
  }
}
