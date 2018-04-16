
import {Component}   from '@angular/core';
import {
  NavigationExtras,
  Router,
} from '@angular/router';
import {AuthService} from '../authentication/auth.service';

@Component({
    selector: 'login-component',
    templateUrl: 'login.component.html',
    styleUrls: ['./login.component.less'],
})

export class LoginComponent {
  username: string;
  password: string;

  constructor(public authService: AuthService, public router: Router) {}

  login() {
    this.authService.login(this.username, this.password)
    .subscribe(response => {
      console.log(response)
      if(response && response.access_token) {
        let redirect = this.authService.redirectUrl ? this.authService.redirectUrl : '/dashboard';

        let navigationExtras: NavigationExtras = {
          queryParamsHandling: 'preserve',
          preserveFragment: true
        };
        // console.log(redirect);
        this.router.navigate([redirect], navigationExtras);
      }
    });
  }
 
  logout() {
    this.authService.logout();
  }
}
