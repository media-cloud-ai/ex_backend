import { Component, Input } from '@angular/core'
import { UserService } from '../services/user.service'
import { User, Role } from '../models/user'

import * as moment from 'moment'

@Component({
  selector: 'user-component',
  templateUrl: 'user.component.html',
  styleUrls: ['./user.component.less'],
})
export class UserComponent {
  @Input() user: User
  @Input() roles: Role[]

  diff: any
  expired = false

  constructor(private userService: UserService) {}

  ngOnInit() {
    const inserted = moment(this.user.inserted_at)
    const now = moment().add(-moment().utcOffset(), 'minutes')
    this.diff = now.diff(inserted)

    const h = now.diff(inserted, 'hours', true)
    if (h > 4) {
      this.expired = true
    }
  }

  updateUserRoles(event) {
    console.log('updateUserRoles', event.checked, event.source.name)

    let roles = this.user.roles
    const edited_role_name = event.source.name
    if (roles === undefined) {
      roles = []
    }

    if (event.checked) {
      // add role
      if (!this.user.roles.includes(edited_role_name)) {
        roles.push(edited_role_name)
      }
    } else {
      // remove role
      const index = this.user.roles.indexOf(edited_role_name)
      if (index > -1) {
        roles.splice(index, 1)
      }
    }

    this.userService.updateRoles(this.user.id, roles).subscribe((response) => {
      console.log('User role updated!', response, this.user)
    })
  }
}
