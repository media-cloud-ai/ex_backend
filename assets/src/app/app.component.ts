
import {Component} from '@angular/core';
import {BreakpointObserver, Breakpoints} from '@angular/cdk/layout';
import {AuthService}    from './authentication/auth.service';
import {Subscription}   from 'rxjs/Subscription';

@Component({
    selector: 'app-component',
    templateUrl: 'app.component.html',
    styleUrls: ['./app.component.less'],
})

export class AppComponent {
  loggedIn: boolean;
  menu_opened: boolean = false;

  subIn: Subscription;
  subOut: Subscription;

  constructor(public authService: AuthService, public breakpointObserver: BreakpointObserver) {
  }

  ngOnInit() {
    this.subIn = this.authService.userLoggedIn$.subscribe(
      username => {
        this.loggedIn = true;
        this.menu_opened = !this.breakpointObserver.isMatched('(max-width: 599px)');
      });
    this.subOut = this.authService.userLoggedOut$.subscribe(
      username => {
        this.loggedIn = false;
        this.menu_opened = false;
      });

    if(this.authService.isLoggedIn) {
      this.loggedIn = true;
      this.menu_opened = !this.breakpointObserver.isMatched('(max-width: 599px)');
    }
  }

  switchMenu(): void {
    this.menu_opened = !this.menu_opened;
  }

  logout() {
    this.authService.logout();
  }
}
