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
  email: string
  username : string
  first_name : string
  last_name : string
  user_id: number
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
    let access_token = this.getToken()
    var currentUser = this.cookieService.get('currentUser')
    if (access_token !== undefined && access_token !== '' &&
      currentUser !== undefined && currentUser !== '') {
      this.isLoggedIn = true
      var parsedUser = JSON.parse(currentUser)
      this.username = parsedUser.email
      this.username = parsedUser.username
      this.first_name = parsedUser.first_name
      this.last_name = parsedUser.last_name
      this.user_id = parsedUser.user_id
      this.roles = parsedUser.roles
    }
  }

  switchRightPanel() {
    this.rightPanelSwitchSource.next('switch')
  }

  login(email, password): Observable<Token> {
    this.isLoggedIn = false
    this.email = undefined
    this.username = undefined
    this.first_name = undefined
    this.last_name = undefined
    this.user_id = undefined
    const query = {session: {
      email: email,
      password: password
    }}

    return this.http.post<Token>('/api/sessions', query).pipe(
      tap(response => {
        console.log("Login: ", response);
        if (response && response.user) {
          this.cookieService.set('currentUser', JSON.stringify({
            email: email,
            username: response.user.username,
            first_name: response.user.first_name,
            last_name: response.user.last_name,
            user_id: response.user.id,
            roles: response.user.roles
          }))

          this.isLoggedIn = true
          this.email = response.user.email
          this.username = response.user.username,
          this.first_name = response.user.first_name,
          this.last_name = response.user.last_name,
          this.roles = response.user.roles
          this.user_id = response.user.id
          this.userLoggedInSource.next(email)
        } else {
          this.isLoggedIn = false
          this.email = undefined
          this.username = undefined
          this.first_name = undefined
          this.last_name = undefined
          this.roles = undefined
          this.user_id = undefined
          this.userLoggedOutSource.next('')
          this.rightPanelSwitchSource.next('close')
        }
      }),
      catchError(this.handleError('login', undefined))
    )
  }

  logout(clean_cookies = true): void {
    this.isLoggedIn = false
    this.email = undefined
    this.username = undefined
    this.first_name = undefined
    this.last_name = undefined
    this.roles = undefined
    this.user_id = undefined
    this.userLoggedOutSource.next('')
    this.cookieService.delete('token')
    this.cookieService.delete('currentUser')
    this.rightPanelSwitchSource.next('close')
    this.router.navigate(['/login'])
  }

  getToken(): string {
    return this.cookieService.get('token');
  }

  getUsername(): string {
    return this.first_name + ' ' + this.last_name
  }

  getId(): number {
    return this.user_id
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
