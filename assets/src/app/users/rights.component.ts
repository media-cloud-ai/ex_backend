
import {Component, Input, ViewChild} from '@angular/core'
import {MatCheckboxModule, PageEvent} from '@angular/material'
import {ActivatedRoute, Router} from '@angular/router'

import {UserService} from '../services/user.service'
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
  editor: boolean

  constructor(
    private userService: UserService,
  ) {}

  ngOnInit() {
    if (this.user && this.user.rights) {
      this.administrator = this.user.rights.includes('administrator')
      this.technician = this.user.rights.includes('technician')
      this.editor = this.user.rights.includes('editor')
    }
  }

  updateAdministratorRight(event, user): void {
    this.updateRight(event, user, 'administrator')
  }

  updateTechnicianRight(event, user): void {
    this.updateRight(event, user, 'technician')
  }

  updateEditorRight(event, user): void {
    this.updateRight(event, user, 'editor')
  }

  updateRight(event, user, kind): void {
    let rights = user.rights
    if (rights === undefined) {
      rights = []
    }

    if (event.checked === false) {
      let index = this.user.rights.indexOf(kind)
      if (index > -1) {
        rights.splice(index, 1)
      }
    }

    if (event.checked === true && !this.user.rights.includes(kind)) {
      rights.push(kind)
    }

    this.userService.updateRights(user.id, rights)
    .subscribe(response => {
    })
  }
}
