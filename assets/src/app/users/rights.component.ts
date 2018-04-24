
import {Component, Input, ViewChild} from '@angular/core';
import {MatCheckboxModule, PageEvent} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';

import {UserService} from '../services/user.service';
import {User} from '../models/user';

@Component({
  selector: 'rights-component',
  templateUrl: 'rights.component.html',
  styleUrls: ['./rights.component.less'],
})

export class RightsComponent {
  @Input() user: User;

  administrator: boolean;
  technician: boolean;
  editor: boolean;

  constructor(
    private userService: UserService,
  ) {}

  ngOnInit() {
    if(this.user && this.user.rights) {
      this.administrator = this.user.rights.indexOf("administrator") != -1;
      this.technician = this.user.rights.indexOf("technician") != -1;
      this.editor = this.user.rights.indexOf("editor") != -1;
    }
  }

  updateAdministratorRight(event, user): void {
    this.updateRight(event, user, "administrator");
  }

  updateTechnicianRight(event, user): void {
    this.updateRight(event, user, "technician");
  }

  updateEditorRight(event, user): void {
    this.updateRight(event, user, "editor");
  }

  updateRight(event, user, kind): void {
    let rights = user.rights;
    if(rights == undefined) {
      rights = []
    }

    if(event.checked == false) {
      let index = this.user.rights.indexOf(kind);
      if(index > -1) {
        rights.splice(index, 1);
      }
    }

    if(event.checked == true && this.user.rights.indexOf(kind) == -1) {
      rights.push(kind);
    }

    this.userService.updateRights(user.id, rights)
    .subscribe(response => {
    });
  }
}
