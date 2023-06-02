import { Component, ViewChild } from '@angular/core'
import { ActivatedRoute, Router } from '@angular/router'

import { Application } from '../models/application'
import { ApplicationService } from '../services/application.service'
import { AuthService } from '../authentication/auth.service'
import { PasswordComponent } from '../password/password.component'

@Component({
  selector: 'reset_password-component',
  templateUrl: 'reset_password.component.html',
  styleUrls: ['./reset_password.component.less'],
})
export class ResetPasswordComponent {
  @ViewChild('password') passwordComponent: PasswordComponent

  application: Application
  validating = false
  validated = false
  error = false
  key: string
  password: string
  sub = undefined

  constructor(
    private applicationService: ApplicationService,
    private authService: AuthService,
    private route: ActivatedRoute,
    public router: Router,
  ) {}

  ngOnInit() {
    this.applicationService.get().subscribe((application) => {
      this.application = application
    })

    this.sub = this.route.queryParams.subscribe((params) => {
      this.key = params['key']
    })
  }

  ngOnDestroy() {
    this.sub.unsubscribe()
  }

  setPasswordAndValidate() {
    this.validating = true
    this.error = false
    this.password = this.passwordComponent.get_password()
    if (!this.password) {
      return undefined
    }
    this.authService
      .confirmResetPassword(this.password, this.key)
      .subscribe((response) => {
        this.validating = false
        if (response) {
          this.validated = true
        } else {
          this.error = true
        }
      })
  }

  goToLogin() {
    this.router.navigate(['/'])
  }
}
