
import {Component, ViewChild} from '@angular/core'
import {MatCheckboxModule} from '@angular/material/checkbox'
import {PageEvent} from '@angular/material/paginator'
import {ActivatedRoute, Router} from '@angular/router'

import {UserService} from '../services/user.service'
import {UserPage} from '../models/page/user_page'
import {User} from '../models/user'

@Component({
  selector: 'users-component',
  templateUrl: 'users.component.html',
  styleUrls: ['./users.component.less'],
})

export class UsersComponent {
  length = 1000
  pageSize = 10
  email: string
  password: string
  error_message: string
  page = 0
  sub = undefined

  pageEvent: PageEvent
  users: UserPage

  constructor(
    private userService: UserService,
    private route: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0
        this.getUsers(this.page)
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

  eventGetUsers(event): void {
    this.router.navigate(['/users'], { queryParams: this.getQueryParamsForPage(event.pageIndex) })
    this.getUsers(event.pageIndex)
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
}
