
import {Component, Input, ViewChild} from '@angular/core'
import {PageEvent} from '@angular/material/paginator'
import {MatCheckboxModule} from '@angular/material/checkbox'
import {ActivatedRoute, Router} from '@angular/router'

import {ApplicationService} from '../services/application.service'
import {UserService} from '../services/user.service'
import {Application} from '../models/application'
import {User} from '../models/user'

@Component({
  selector: 'rights-component',
  templateUrl: 'rights.component.html',
  styleUrls: ['./rights.component.less'],
})

export class RightsComponent {
  @Input() user: User

  administrator: boolean
  technician: boolean
  manager: boolean
  editor: boolean
  ftvstudio: boolean

  application: Application

  constructor(
    private applicationService: ApplicationService,
    private userService: UserService,
  ) {}

  ngOnInit() {
    if (this.user && this.user.roles) {
      this.administrator = this.user.roles.includes('administrator')
      this.technician = this.user.roles.includes('technician')
      this.manager = this.user.roles.includes('manager')
      this.editor = this.user.roles.includes('editor')
      this.ftvstudio = this.user.roles.includes('ftvstudio')
    }

    this.applicationService.get()
    .subscribe(application => {
      this.application = application
    })
  }

  updateAdministratorRight(event, user): void {
    this.updateRight(event, user, ['administrator'])
  }

  updateTechnicianRight(event, user): void {
    this.updateRight(event, user, ['technician'])
  }

  updateEditorRight(event, user): void {
    this.updateRight(event, user, ['editor'])
  }

  updateFtvStudioRight(event, user): void {
    this.updateRight(event, user, ['ftvstudio'])
  }

  updateVidtextAdministratorRight(event, user): void {
    this.updateRight(event, user, ['administrator', 'technician'])
  }

  updateVidtextEditorRight(event, user): void {
    this.updateRight(event, user, ['manager'])
  }

  updateVidtextAuthorRight(event, user): void {
    this.updateRight(event, user, ['editor'])
  }

  updateRight(event, user: User, kind): void {
    let roles = user.roles
    if (roles === undefined) {
      roles = []
    }

    if (event.checked === false) {
      for (let item of kind) {
        let index = this.user.roles.indexOf(item)
        if (index > -1) {
          roles.splice(index, 1)
        }
      }
    }

    if (event.checked === true) {
      for (let item of kind) {
        if(!this.user.roles.includes(item))
        roles.push(item)
      }
    }
    console.log(roles);

    this.userService.updateRoles(user.id, roles)
    .subscribe(response => {
    })
  }
}
