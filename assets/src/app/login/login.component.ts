import { Location } from '@angular/common'
import { Component, ViewChild } from '@angular/core'
import { NavigationExtras, Router } from '@angular/router'

import { Application } from '../models/application'
import { ApplicationService } from '../services/application.service'
import { AuthService } from '../authentication/auth.service'

import { MatDialog } from '@angular/material/dialog'
import { EnterEmailDialogComponent } from './dialogs/enter_email_dialog.component'
import { PasswordComponent } from '../password/password.component'

@Component({
  selector: 'login-component',
  templateUrl: 'login.component.html',
  styleUrls: ['./login.component.less'],
})
export class LoginComponent {
  @ViewChild('password') passwordComponent: PasswordComponent

  username: string
  password: string
  message: string
  application: Application

  constructor(
    private applicationService: ApplicationService,
    public authService: AuthService,
    private dialog: MatDialog,
    private location: Location,
    public router: Router,
  ) {}

  ngOnInit() {
    this.authService.getSession().subscribe((_) => {
      this.redirect()
    })
    this.applicationService.get().subscribe((response) => {
      this.application = response
    })
  }

  login() {
    this.password = this.passwordComponent.get_password()
    this.authService
      .login(this.username, this.password)
      .subscribe((response) => {
        this.message = ''
        if (response && response.user) {
          this.redirect()
        } else {
          this.message = 'Bad username and/or password'
        }
      })
  }

  sso(provider: string) {
    const url = this.location.prepareExternalUrl('auth/' + provider + '/new')
    window.location.replace(url)
  }

  sso_enabled(): boolean {
    let enabled = false
    for (const provider of this.application.providers) {
      if (provider.enabled) {
        enabled = true
        break
      }
    }
    return enabled
  }

  redirect() {
    const redirect = this.authService.redirectUrl
      ? this.authService.redirectUrl
      : '/dashboard'

    const navigationExtras: NavigationExtras = {
      queryParamsHandling: 'preserve',
      preserveFragment: true,
    }
    this.router.navigate([redirect], navigationExtras)
  }

  logout() {
    this.authService.logout().subscribe()
  }

  openResetPasswordDialog(): void {
    const _dialogRef = this.dialog.open(EnterEmailDialogComponent, {
      data: {
        email: '',
        message: '',
      },
    })
  }
}
