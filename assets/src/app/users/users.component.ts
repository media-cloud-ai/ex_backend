import { Component } from '@angular/core'
import { ActivatedRoute, Router } from '@angular/router'
import { MatDialog } from '@angular/material/dialog'

import { AuthService } from '../authentication/auth.service'
import { UserService } from '../services/user.service'
import { RolePage, UserPage } from '../models/page/user_page'
import { Right, Role, RoleEvent, RoleEventAction } from '../models/user'
import { RoleOrRightDeletionDialogComponent } from './dialogs/role_or_right_deletion_dialog.component'
import { UserDeletionDialogComponent } from './dialogs/user_deletion_dialog.component'
import { UserAdditionDialogComponent } from './dialogs/user_addition_dialog.component'
import { UserEditionDialogComponent } from './dialogs/user_edition_dialog.component'
import { UserPasswordEditionDialogComponent } from './dialogs/user_password_edition_dialog.component'
import { UserShowCredentialsDialogComponent } from './dialogs/user_show_credentials_dialog.component'
import { UserShowValidationLinkDialogComponent } from './dialogs/user_show_validation_link_dialog.component'

@Component({
  selector: 'users-component',
  templateUrl: 'users.component.html',
  styleUrls: ['./users.component.less'],
})
export class UsersComponent {
  length = 1000
  pageSizeOptions = [20, 50, 100]
  pageSize = this.pageSizeOptions[0]
  email: string
  first_name: string
  last_name: string
  password: string
  user_error_message: string
  page = 0
  sub = undefined

  users: UserPage
  search = ''

  roles: RolePage
  roles_total = 1000
  all_roles: RolePage
  selected_role_id = undefined
  rights: Right[] = []
  right_administrator: boolean
  available_permissions: string[]
  already_set_entity: string[] = []
  new_role_name: string
  role_error_message: string
  current_user_id: number

  constructor(
    private userService: UserService,
    private route: ActivatedRoute,
    private router: Router,
    private dialog: MatDialog,
    public authService: AuthService,
  ) {}

  ngOnInit() {
    this.right_administrator = this.authService.hasAdministratorRight()
    this.current_user_id = this.authService.getId()
    this.sub = this.route.queryParams.subscribe((params) => {
      this.page = +params['page'] || 0
      this.getUsers(this.page)
      this.getRoles(this.page)
      this.getAllRoles()
    })
  }

  ngOnDestroy() {
    this.sub.unsubscribe()
  }

  getUsers(index): void {
    this.userService
      .getUsers(index, this.pageSize, this.search)
      .subscribe((userPage) => {
        this.users = userPage
        if (userPage) {
          this.length = userPage.total
        } else {
          this.length = 0
        }
      })
  }

  getRoles(index): void {
    this.userService.getRoles(index, this.pageSize).subscribe((roles) => {
      this.roles = roles
      if (roles) {
        this.roles_total = roles.total
        for (const role of this.roles.data) {
          role.rights.forEach((right) => this.rights.push(right))
        }
      } else {
        this.roles_total = 0
      }
    })
    this.userService.getRightDefinitions().subscribe((rightDefinitions) => {
      this.available_permissions = rightDefinitions.rights
    })
  }

  getAllRoles(): void {
    this.userService.getAllRoles().subscribe((roles) => {
      this.all_roles = roles
    })
  }

  eventGetUsers(event): void {
    // this.router.navigate(['/users'], { queryParams: this.getQueryParamsForPage(event.pageIndex) })
    this.getUsers(event.pageIndex)
  }

  eventGetRoles(event): void {
    this.getRoles(event.pageIndex)
  }

  inviteUser(): void {
    const dialogRef = this.dialog.open(UserAdditionDialogComponent, {})
    dialogRef.afterClosed().subscribe((_response) => {
      this.getUsers(0)
    })
  }

  validationLink(user): void {
    this.userService
      .generateValidationLink(user)
      .subscribe((validation_link) => {
        const dialogRef = this.dialog.open(
          UserShowValidationLinkDialogComponent,
          {
            data: {
              user: user,
              validation_link: validation_link,
            },
          },
        )

        dialogRef.afterClosed().subscribe((_response) => {
          this.getUsers(this.page)
        })
      })
  }

  generateCredentials(user): void {
    this.userService.generateCredentials(user).subscribe((response_user) => {
      const dialogRef = this.dialog.open(UserShowCredentialsDialogComponent, {
        data: {
          user: response_user,
        },
      })

      dialogRef.afterClosed().subscribe((_response) => {
        this.getUsers(this.page)
      })
    })
  }

  editUser(user): void {
    const dialogRef = this.dialog.open(UserEditionDialogComponent, {
      data: {
        user: user,
      },
    })

    dialogRef.afterClosed().subscribe((_response) => {
      this.getUsers(this.page)
    })
  }

  changeUserPassword(user): void {
    const dialogRef = this.dialog.open(UserPasswordEditionDialogComponent, {
      data: {
        user: user,
      },
    })

    dialogRef.afterClosed().subscribe((_response) => {
      this.getUsers(this.page)
    })
    // this.userService.changeUserPassword(user, password)
  }

  removeUser(user): void {
    // Ask for confirmation
    const dialogRef = this.dialog.open(UserDeletionDialogComponent, {
      data: {
        user: user,
      },
    })

    dialogRef.afterClosed().subscribe((response) => {
      if (response) {
        this.userService.removeUser(user.id).subscribe((_response) => {
          this.getUsers(this.page)
        })
      }
    })
  }

  getQueryParamsForPage(pageIndex: number): Record<string, unknown> {
    const params = {}
    if (pageIndex !== 0) {
      params['page'] = pageIndex
    }
    return params
  }

  createRole() {
    const role = new Role(this.new_role_name)
    this.role_error_message = ''
    this.userService.createRole(role).subscribe((role) => {
      if (!role) {
        this.role_error_message = 'Unable to create role'
      }
      this.getRoles(this.page)
    })
  }

  roleHasChanged(event: RoleEvent) {
    if (event.action == RoleEventAction.Select) {
      this.selected_role_id = event.role.id
    }

    if (event.action == RoleEventAction.Update) {
      this.userService.updateRole(event.role).subscribe((_role) => {
        // console.log("Updated role:", role);
        this.getRoles(this.page)
      })
      this.selected_role_id = undefined
    }

    if (event.action == RoleEventAction.Delete) {
      // Ask for confirmation
      const dialogRef = this.dialog.open(RoleOrRightDeletionDialogComponent, {
        data: {
          role: event.role,
        },
      })

      dialogRef.afterClosed().subscribe((response) => {
        if (response) {
          this.userService.deleteRole(event.role).subscribe((_role) => {
            // console.log("Deleted role:", role);
            this.userService
              .deleteUsersRole(event.role)
              .subscribe((_updatedUsers) => {
                // console.log("Updated role users:", updatedUsers);
                this.getUsers(this.page)
              })
            this.getRoles(this.page)
          })
        }
      })
    }
  }
}
