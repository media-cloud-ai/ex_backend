import {Injectable, Component, OnDestroy} from '@angular/core';
import {Router} from '@angular/router';
import {HttpClient, HttpParams, HttpHeaders} from '@angular/common/http';
import {Observable} from 'rxjs/Observable';
import {of} from 'rxjs/observable/of';
import {catchError, map, tap} from 'rxjs/operators';
import {Subject} from 'rxjs/Subject';
import {Subscription} from 'rxjs/Subscription';
import {Token} from '../models/token';
import 'rxjs/add/operator/do';

@Injectable()
export class AuthService {
  isLoggedIn = false;
  token : string;
  username : string;
  rights : any;
  redirectUrl: string;

  private userLoggedInSource = new Subject<string>();
  private userLoggedOutSource = new Subject<string>();
  private rightPanelSwitchSource = new Subject<string>();

  userLoggedIn$ = this.userLoggedInSource.asObservable();
  userLoggedOut$ = this.userLoggedOutSource.asObservable();
  rightPanelSwitch$ = this.rightPanelSwitchSource.asObservable();

  subPanelSwitch: Subscription;

  constructor(private http: HttpClient, public router: Router) {
    var currentUser = sessionStorage.getItem('currentUser');
    if(currentUser != undefined && currentUser != "") {
      this.isLoggedIn = true;
      var parsedUser = JSON.parse(currentUser);
      this.token = parsedUser.token;
      this.username = parsedUser.username;
      this.rights = parsedUser.rights;
    }
  }

  switchRightPanel() {
    this.rightPanelSwitchSource.next("switch");
  }

  login(email, password): Observable<Token> {
    this.isLoggedIn = false;
    this.token = undefined;
    this.username = undefined;
    const query = {session: {
      email: email,
      password: password
    }}

    return this.http.post<Token>('/api/sessions', query).pipe(
      tap(response => {
        if (response && response.access_token) {
          sessionStorage.setItem('currentUser', JSON.stringify({
            username: email,
            token: response.access_token,
            rights: response.user.rights
          }));
          this.isLoggedIn = true;
          this.token = response.access_token;
          this.username = email;
          this.rights = response.user.rights;
          this.userLoggedInSource.next(email);
        } else {
          this.isLoggedIn = false;
          this.token = undefined;
          this.username = undefined;
          this.rights = undefined;
          this.userLoggedOutSource.next("");
          this.rightPanelSwitchSource.next("close");
        }
      }),
      catchError(this.handleError('login', undefined))
    );
  }

  logout(): void {
    this.isLoggedIn = false;
    this.token = undefined;
    this.username = undefined;
    this.rights = undefined;
    this.userLoggedOutSource.next("");
    sessionStorage.removeItem('currentUser');
    this.rightPanelSwitchSource.next("close");
    this.router.navigate(["/login"]);
  }

  getToken(): string {
    return this.token;
  }

  hasAdministratorRight(): boolean {
    return this.rights.indexOf("administrator") != -1;
  }

  hasTechnicianRight(): boolean {
    return this.rights.indexOf("technician") != -1;
  }

  hasEditorRight(): boolean {
    return this.rights.indexOf("editor") != -1;
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      console.error(error);
      this.log(`${operation} failed: ${error.message}`);
      return of(result as T);
    };
  }

  private log(message: string) {
    console.log('LoginService: ' + message);
  }
}
