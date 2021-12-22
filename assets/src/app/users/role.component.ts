
import {Component, EventEmitter, Input, Output, ViewChild} from '@angular/core'
import {PageEvent} from '@angular/material/paginator'
import {MatCheckboxModule} from '@angular/material/checkbox'
import {ActivatedRoute, Router} from '@angular/router'

import {UserService} from '../services/user.service'
import {Role, Right, RoleEvent, RoleEventAction} from '../models/user'

@Component({
  selector: 'role-component',
  templateUrl: 'role.component.html',
  styleUrls: ['./role.component.less'],
})
export class RoleComponent {
  @Input() role: Role
  @Output() roleChange = new EventEmitter<RoleEvent>();

  @Input() permissions: string[]

  active_rights: Right[] = []

  new_right: Right;

  role_is_being_edited: boolean = false;

  constructor(
    private userService: UserService,
  ) {}

  ngOnInit() {
    for (let right of this.role.rights) {
       let permission = right;
       if(permission.action.includes("*")) {
         permission.action = this.permissions.slice();
       }
       this.active_rights.push(permission);
    }
  }

  editRightScope(event, right?: Right) {
    let edited_right: Right;
    if (right) {
      // Edit an exisiting right
      edited_right = right;
    } else {
      // Declare a new right
      this.new_right = new Right();
      edited_right = this.new_right;
    }

    edited_right.entity = event.target.value;

    this.role_is_being_edited = true;
  }

  editRightPermissions(event, right?: Right) {
    let edited_right: Right;
    if (right) {
      // Edit an existing right
      edited_right = right;
    } else {
      // Edit a new right
      if (!this.new_right) {
        console.error("No new right, this should not happen!");
        this.new_right = new Right();
      }
      edited_right = this.new_right;
    }

    if (event.checked) {
      edited_right.action.push(event.source.name);
    } else {
      const index = edited_right.action.indexOf(event.source.name);
      if (index > -1) {
        edited_right.action.splice(index, 1);
      }
    }

    this.role_is_being_edited = true;
  }

  deleteRight(right: Right) {
    const index = this.role.rights.indexOf(right);
    if (index > -1) {
      this.role.rights.splice(index, 1);
    }
    console.log(this.role);
    this.roleChange.emit(new RoleEvent(RoleEventAction.Update, this.role));
  }

  updateRole() {
    if (this.new_right) {
      this.role.rights.push(this.new_right);
      this.new_right = undefined;
    }

    this.roleChange.emit(new RoleEvent(RoleEventAction.Update, this.role));
  }

  deleteRole(role: Role) {
    // TODO: ask for confirmation
    this.roleChange.emit(new RoleEvent(RoleEventAction.Delete, this.role));
  }
}
