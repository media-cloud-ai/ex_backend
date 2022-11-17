import {Component, EventEmitter, Input, Output} from '@angular/core'
import {MatDialog} from '@angular/material/dialog'

import {UserService} from '../services/user.service'
import {Right, Role, RoleEvent, RoleEventAction} from '../models/user'
import {RoleOrRightDeletionDialogComponent} from './dialogs/role_or_right_deletion_dialog.component'

@Component({
  selector: 'role-component',
  templateUrl: 'role.component.html',
  styleUrls: ['./role.component.less'],
})

export class RoleComponent {
  @Input() role: Role
  @Input() permissions: string[]
  @Input() selected_role: number

  @Output() roleChange = new EventEmitter<RoleEvent>();

  active_rights: Right[] = []
  new_right: Right;
  is_being_updated: boolean = false;

  constructor(
    private userService: UserService,
    private dialog: MatDialog,
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

    this.selectRole();
    this.is_being_updated = true;
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

    this.selectRole();
    this.is_being_updated = true;
  }

  deleteRight(right: Right) {
    // Ask for confirmation
    let dialogRef = this.dialog.open(RoleOrRightDeletionDialogComponent, {data: {
        'right': right
      }})

    dialogRef.afterClosed().subscribe(response => {
        if(response) {
          const index = this.role.rights.indexOf(right);
          if (index > -1) {
            this.role.rights.splice(index, 1);
          }
          this.roleChange.emit(new RoleEvent(RoleEventAction.Update, this.role));
        }
      });
  }

  updateRole() {
    if (this.new_right) {
      this.role.rights.push(this.new_right);
      this.new_right = undefined;
    }

    this.roleChange.emit(new RoleEvent(RoleEventAction.Update, this.role));
  }

  deleteRole() {
    this.roleChange.emit(new RoleEvent(RoleEventAction.Delete, this.role));
  }

  selectRole(){
    this.roleChange.emit(new RoleEvent(RoleEventAction.Select, this.role))
  }
}
