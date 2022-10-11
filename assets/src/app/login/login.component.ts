
import { Component } from '@angular/core'
import {
  NavigationExtras,
  Router,
} from '@angular/router'

import { Application } from '../models/application'
import { ApplicationService } from '../services/application.service'
import { AuthService } from '../authentication/auth.service'

import { MatDialog } from '@angular/material/dialog'
import { EnterEmailDialogComponent } from './dialogs/enter_email_dialog.component'

@Component({
  selector: 'login-component',
  templateUrl: 'login.component.html',
  styleUrls: ['./login.component.less'],
})

export class LoginComponent {
  username: string
  password: string
  message: string
  application: Application

  constructor(
    private applicationService: ApplicationService,
    public authService: AuthService,
    private dialog: MatDialog,
    public router: Router) { }

  ngOnInit() {
    this.applicationService.get()
      .subscribe(response => {
        this.application = response
      })
  }

  login() {
    this.authService.login(this.username, this.password)
      .subscribe(response => {
        this.message = ''
        if (response && response.user) {
          let redirect = this.authService.redirectUrl ? this.authService.redirectUrl : '/dashboard'

          let navigationExtras: NavigationExtras = {
            queryParamsHandling: 'preserve',
            preserveFragment: true
          }
          this.router.navigate([redirect], navigationExtras)
        } else {
          this.message = 'Bad username and/or password'
        }
      })
  }

  logout() {
    this.authService.logout()
  }

  openResetPasswordDialog(): void {
    let dialogRef = this.dialog.open(EnterEmailDialogComponent, {
      data: {
        'email': '', 'message': ''
      }
    })
  }
}
