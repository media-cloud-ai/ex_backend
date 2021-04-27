
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
    if (this.user && this.user.rights) {
      this.administrator = this.user.rights.includes('administrator')
      this.technician = this.user.rights.includes('technician')
      this.manager = this.user.rights.includes('manager')
      this.editor = this.user.rights.includes('editor')
      this.ftvstudio = this.user.rights.includes('ftvstudio')
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

  updateRight(event, user, kind): void {
    let rights = user.rights
    if (rights === undefined) {
      rights = []
    }

    if (event.checked === false) {
      for (let item of kind) {
        let index = this.user.rights.indexOf(item)
        if (index > -1) {
          rights.splice(index, 1)
        }
      }
    }

    if (event.checked === true) {
      for (let item of kind) {
        if(!this.user.rights.includes(item))
        rights.push(item)
      }
    }
    console.log(rights);

    this.userService.updateRights(user.id, rights)
    .subscribe(response => {
    })
  }
}
