import {Injectable, Component, OnDestroy} from '@angular/core'
import {Router} from '@angular/router'
import {HttpClient, HttpParams, HttpHeaders} from '@angular/common/http'
import {CookieService} from 'ngx-cookie-service'
import {Observable, of, Subject, Subscription} from 'rxjs'
import {catchError, map, tap} from 'rxjs/operators'
import {Token} from '../models/token'
import 'rxjs/add/operator/do'

import {UserService} from '../services/user.service'

@Injectable()
export class AuthService {
  isLoggedIn = false
  token : string
  username : string
  roles : string[]
  redirectUrl: string

  private userLoggedInSource = new Subject<string>()
  private userLoggedOutSource = new Subject<string>()
  private rightPanelSwitchSource = new Subject<string>()

  userLoggedIn$ = this.userLoggedInSource.asObservable()
  userLoggedOut$ = this.userLoggedOutSource.asObservable()
  rightPanelSwitch$ = this.rightPanelSwitchSource.asObservable()

  subPanelSwitch: Subscription

  constructor(
    private cookieService: CookieService,
    private http: HttpClient,
    private userService: UserService,
    public router: Router
  ) {
    var currentUser = this.cookieService.get('currentUser')
    if (currentUser !== undefined && currentUser !== '') {
      this.isLoggedIn = true
      var parsedUser = JSON.parse(currentUser)
      this.token = parsedUser.token
      this.username = parsedUser.username
      this.roles = parsedUser.roles
    }
  }

  switchRightPanel() {
    this.rightPanelSwitchSource.next('switch')
  }

  login(email, password): Observable<Token> {
    this.isLoggedIn = false
    this.token = undefined
    this.username = undefined
    const query = {session: {
      email: email,
      password: password
    }}

    return this.http.post<Token>('/api/sessions', query).pipe(
      tap(response => {
        console.log("Login: ", response);
        if (response && response.access_token) {
          this.cookieService.set('currentUser', JSON.stringify({
            username: email,
            token: response.access_token,
            roles: response.user.roles
          }))

          this.isLoggedIn = true
          this.token = response.access_token
          this.username = email
          this.roles = response.user.roles
          this.userLoggedInSource.next(email)
        } else {
          this.isLoggedIn = false
          this.token = undefined
          this.username = undefined
          this.roles = undefined
          this.userLoggedOutSource.next('')
          this.rightPanelSwitchSource.next('close')
        }
      }),
      catchError(this.handleError('login', undefined))
    )
  }

  logout(): void {
    this.isLoggedIn = false
    this.token = undefined
    this.username = undefined
    this.roles = undefined
    this.userLoggedOutSource.next('')
    this.cookieService.delete('currentUser')
    this.rightPanelSwitchSource.next('close')
    this.router.navigate(['/login'])
  }

  getToken(): string {
    return this.token
  }

  getUsername(): string {
    return this.username
  }

  hasAdministratorRight(): boolean {
    console.log("hasAdministratorRight", this.roles);
    if (!this.roles){
      return false
    }
    return this.roles.includes('administrator')
  }

  hasTechnicianRight(): boolean {
    if (!this.roles){
      return false
    }
    return this.roles.includes('technician')
  }

  hasEditorRight(): boolean {
    if (!this.roles){
      return false
    }
    return this.roles.includes('editor')
  }

  hasAnyRights(entity: string, action: string): Observable<any> {
    if (!this.roles){
      return of(false)
    }
    if (entity === undefined || action == undefined){
      return of(false)
    }
    let params = new HttpParams()
    params = params.append('entity', entity)
    params = params.append('action', action)

    return this.http.post<any>('/api/users/check_rights', params)
      .pipe(
        tap(userPage => this.log('Check Rights')),
        catchError(this.handleError('checkRights', undefined))
      )
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      console.error(error)
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('LoginService: ' + message)
  }
}
