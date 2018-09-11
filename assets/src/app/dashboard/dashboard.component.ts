
import {Component} from '@angular/core'
import {AuthService}    from '../authentication/auth.service'
import {Subscription}   from 'rxjs'

import {ApplicationService} from '../services/application.service'
import {Application} from '../models/application'

@Component({
    selector: 'dashboard-component',
    templateUrl: 'dashboard.component.html',
})

export class DashboardComponent {
  right_administrator: boolean
  right_technician: boolean
  right_editor: boolean
  application: Application

  subIn: Subscription
  subOut: Subscription

  constructor(
    private applicationService: ApplicationService,
    public authService: AuthService
  ) {}

  ngOnInit() {
    this.subIn = this.authService.userLoggedIn$.subscribe(
      username => {
        this.right_administrator = this.authService.hasAdministratorRight()
        this.right_technician = this.authService.hasTechnicianRight()
        this.right_editor = this.authService.hasEditorRight()
      })
    this.subOut = this.authService.userLoggedOut$.subscribe(
      username => {
        delete this.right_administrator
        delete this.right_technician
        delete this.right_editor
      })

    if (this.authService.isLoggedIn) {
      this.right_administrator = this.authService.hasAdministratorRight()
      this.right_technician = this.authService.hasTechnicianRight()
      this.right_editor = this.authService.hasEditorRight()
    }

    this.applicationService.get()
    .subscribe(application => {
      this.application = application
    })
  }
}
