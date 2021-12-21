
import {Component, ViewChild} from '@angular/core'
import {MatCheckboxModule} from '@angular/material/checkbox'
import {PageEvent} from '@angular/material/paginator'
import {ActivatedRoute, Router} from '@angular/router'
import {MatDialog} from '@angular/material/dialog'

import {UserService} from '../services/user.service'
import {UserPage, RolePage} from '../models/page/user_page'
import {User, Role, Right} from '../models/user'
import {UserShowCredentialsDialogComponent} from './dialogs/user_show_credentials_dialog.component'

@Component({
  selector: 'users-component',
  templateUrl: 'users.component.html',
  styleUrls: ['./users.component.less'],
})

export class UsersComponent {
  length = 1000
  pageSizeOptions = [
    20,
    50,
    100
  ]
  pageSize = this.pageSizeOptions[0];
  email: string
  password: string
  error_message: string
  page = 0
  sub = undefined

  pageEvent: PageEvent
  users: UserPage

  roles: RolePage
  rights: Right[] = []
  available_permissions: string[]
  already_set_entity: string[] = []

  constructor(
    private userService: UserService,
    private route: ActivatedRoute,
    private router: Router,
    private dialog: MatDialog
  ) {}

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0
        this.getUsers(this.page)
        this.getRoles(this.page)
      })
  }

  ngOnDestroy() {
    this.sub.unsubscribe()
  }

  getUsers(index): void {
    this.userService.getUsers(index, this.pageSize)
    .subscribe(userPage => {
      this.users = userPage
      if (userPage) {
        this.length = userPage.total
      } else {
        this.length = 0
      }
    })
  }

  getRoles(index): void {
    this.userService.getRoles(index, this.pageSize)
      .subscribe(roles => {
        this.roles = roles;
        for(let role of this.roles.data) {
          role.rights.forEach((right) => this.rights.push(right));
        }
      });
    this.userService.getRightDefinitions()
    .subscribe(rightDefinitions => {
        this.available_permissions = rightDefinitions.rights;
      });
  }

  eventGetUsers(event): void {
    this.router.navigate(['/users'], { queryParams: this.getQueryParamsForPage(event.pageIndex) })
    this.getUsers(event.pageIndex)
  }

  eventGetRoles(event): void {
    this.getRoles(this.page);
  }

  inviteUser(): void {
    this.error_message = ''
    this.userService.inviteUser(this.email)
    .subscribe(response => {
      console.log(response)
      if (response === undefined) {
        this.error_message = 'Unable to create user'
      } else {
        this.email = ''
        this.password = ''
        this.getUsers(0)
      }
    })
  }

  generateCredentials(user): void {
    this.userService.generateCredentials(user)
    .subscribe(response_user => {
      let dialogRef = this.dialog.open(UserShowCredentialsDialogComponent, {data: {
        'user': response_user
      }})

      dialogRef.afterClosed().subscribe(response => {
        this.getUsers(this.page)
      })
    })
  }

  removeUser(user_id): void {
    this.userService.removeUser(user_id)
    .subscribe(response => {
      this.getUsers(this.page)
    })
  }

  getQueryParamsForPage(pageIndex: number): Object {
    var params = {}
    if (pageIndex !== 0) {
      params['page'] = pageIndex
    }
    return params
  }

  roleHasChanged(role: Role) {
    // console.log("roleHasChanged", role);
    this.userService.updateRole(role).subscribe(role => console.log("Updated role:", role));
    this.getRoles(this.page);
  }
}
