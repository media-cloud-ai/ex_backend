import { Injectable } from '@angular/core'
import { Router } from '@angular/router'
import { HttpClient } from '@angular/common/http'
import { Observable, of, Subject } from 'rxjs'
import { catchError, tap } from 'rxjs/operators'
import { CookieService } from 'ngx-cookie-service'

import { Confirm, UserRights } from '../models/user'
import { PasswordReset, PasswordResetError } from '../models/password_reset'
import { Token } from '../models/token'

@Injectable()
export class AuthService {
  isLoggedIn = false
  email: string
  username: string
  first_name: string
  last_name: string
  user_id: number
  roles: string[]
  redirectUrl: string

  private userLoggedInSource = new Subject<string>()
  private userLoggedOutSource = new Subject<string>()
  private rightPanelSwitchSource = new Subject<string>()

  userLoggedIn$ = this.userLoggedInSource.asObservable()
  userLoggedOut$ = this.userLoggedOutSource.asObservable()

  constructor(
    private http: HttpClient,
    public router: Router,
    public cookies: CookieService,
  ) {
    // This should be reworked to have minimal information on client-side
    // See Issue #605
    const access_token = this.getToken()
    const currentUser = this.getCurrentUser()
    if (
      access_token !== undefined &&
      access_token !== null &&
      access_token !== '' &&
      currentUser !== undefined &&
      currentUser !== null &&
      currentUser !== ''
    ) {
      this.isLoggedIn = true
      const parsedUser = JSON.parse(currentUser)
      this.email = parsedUser.email
      this.username = parsedUser.username
      this.first_name = parsedUser.first_name
      this.last_name = parsedUser.last_name
      this.user_id = parsedUser.user_id
      this.roles = parsedUser.roles
    }
  }

  login(email, password): Observable<Token> {
    this.isLoggedIn = false
    this.email = undefined
    this.username = undefined
    this.first_name = undefined
    this.last_name = undefined
    this.user_id = undefined
    const query = {
      session: {
        email: email,
        password: password,
      },
    }

    return this.http.post<Token>('/api/sessions', query).pipe(
      tap((response) => {
        if (response && response.user) {
          this.setSession(response)
        } else {
          this.clearSession()
        }
      }),
      catchError(this.handleError('login', undefined)),
    )
  }

  logout(authorized = true, _clean_cookies = true): Observable<[]> {
    if (!authorized) {
      this.clearSession()
      this.router.navigate(['/login'])
      return of([])
    } else {
      return this.http.delete<[]>('/api/sessions').pipe(
        tap((_) => {
          this.clearSession()
          this.router.navigate(['/login'])
        }),
        catchError(this.handleError('login', undefined)),
      )
    }
  }

  getToken(): string {
    return this.cookies.get('token')
  }

  private getCurrentUser(): string {
    return this.cookies.get('currentUser')
  }

  getSession(): Observable<Token> {
    return this.http.get<Token>('/api/sessions/verify').pipe(
      tap((response) => {
        if (response && response.user) {
          this.setSession(response)
        }
      }),
      catchError(this.handleError('login', undefined)),
    )
  }

  private setSession(response: Token): void {
    this.cookies.set('token', response.access_token)
    this.cookies.set(
      'currentUser',
      JSON.stringify({
        email: response.user.email,
        username: response.user.username,
        first_name: response.user.first_name,
        last_name: response.user.last_name,
        user_id: response.user.id,
        roles: response.user.roles,
      }),
    )
    this.isLoggedIn = true
    this.email = response.user.email
    this.username = response.user.username
    this.first_name = response.user.first_name
    this.last_name = response.user.last_name
    this.user_id = response.user.id
    this.roles = response.user.roles
    this.userLoggedInSource.next(response.user.email)
  }

  private clearSession(): void {
    this.isLoggedIn = false

    this.email = undefined
    this.username = undefined
    this.first_name = undefined
    this.last_name = undefined
    this.roles = undefined
    this.user_id = undefined

    this.userLoggedOutSource.next('')

    this.cookies.delete('token')
    this.cookies.delete('currentUser')

    this.rightPanelSwitchSource.next('close')
  }

  getUsername(): string {
    return this.first_name + ' ' + this.last_name
  }

  getId(): number {
    return this.user_id
  }

  hasAdministratorRight(): boolean {
    console.log('hasAdministratorRight', this.roles)
    if (!this.roles) {
      return false
    }
    return this.roles.includes('administrator')
  }

  hasTechnicianRight(): boolean {
    if (!this.roles) {
      return false
    }
    return this.roles.includes('technician')
  }

  hasEditorRight(): boolean {
    if (!this.roles) {
      return false
    }
    return this.roles.includes('editor')
  }

  hasAnyRights(entity: string, actions: string[]): Observable<UserRights> {
    if (!this.roles) {
      return of(UserRights.empty())
    }
    if (entity === undefined || actions == undefined || actions.length == 0) {
      return of(UserRights.empty())
    }

    const body = {
      entity: entity,
      actions: actions,
    }

    return this.http.post<UserRights>('/api/users/check_rights', body).pipe(
      tap((_actionRights) => this.log('Check Rights')),
      catchError(this.handleError('checkRights', undefined)),
    )
  }

  passwordResetRequest(email: string): Observable<PasswordReset> {
    const params = {
      password_reset: {
        email: email,
      },
    }

    return this.http.post<PasswordReset>('/api/password_resets', params).pipe(
      tap((_userPage) => this.log('Reset password')),
      catchError((err) => this.handleErrorPasswordReset(err)),
    )
  }

  confirmResetPassword(password: string, key: string): Observable<Confirm> {
    const params = {
      password_reset: {
        password: password,
        key: key,
      },
    }

    return this.http.put<Confirm>('/api/password_resets/update', params).pipe(
      tap((_user) => this.log('fetched Confirm Password Reset')),
      catchError(this.handleError('confirmResetPassword', undefined)),
    )
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      console.error(error)
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private handleErrorPasswordReset(
    err_object: PasswordResetError,
  ): Observable<PasswordReset> {
    console.error(err_object)
    this.log(err_object.message)
    return of(new PasswordReset('', err_object.error.custom_error_message))
  }

  private log(message: string) {
    console.log('LoginService: ' + message)
  }
}
