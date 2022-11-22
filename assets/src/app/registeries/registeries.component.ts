import { Component } from '@angular/core'
import { ActivatedRoute, Router } from '@angular/router'

import { RegisteryService } from '../services/registery.service'
import { RegisteryPage } from '../models/page/registery_page'

@Component({
  selector: 'registeries-component',
  templateUrl: 'registeries.component.html',
  styleUrls: ['./registeries.component.less'],
})
export class RegisteriesComponent {
  length = 1000
  pageSize = 10
  pageSizeOptions = [10, 20, 50, 100]
  page = 0
  sub = undefined
  loading = true

  searchInput = ''
  items: RegisteryPage

  constructor(
    private registeryService: RegisteryService,
    private route: ActivatedRoute,
    private router: Router,
  ) {}

  ngOnInit() {
    this.sub = this.route.queryParams.subscribe((params) => {
      this.page = +params['page'] || 0
      this.pageSize = +params['per_page'] || 10
      this.searchInput = params['search'] || ''
      this.getRegisteries(this.page)
    })
  }

  ngOnDestroy() {
    this.sub.unsubscribe()
  }

  getRegisteries(index): void {
    this.loading = true
    this.registeryService
      .getRegisteries(index, this.pageSize, this.searchInput)
      .subscribe((page) => {
        this.loading = false

        if (page === undefined) {
          this.items = new RegisteryPage()
          this.length = undefined
          return
        }

        this.items = page
        this.length = page.total
      })
  }

  updateRegisteries(): void {
    this.router.navigate(['/registeries'], {
      queryParams: this.getQueryParamsForPage(0),
    })
    this.getRegisteries(0)
  }

  eventGetRegisteries(event): void {
    this.router.navigate(['/registeries'], {
      queryParams: this.getQueryParamsForPage(event.pageIndex, event.pageSize),
    })
  }

  getQueryParamsForPage(
    pageIndex: number,
    pageSize: number = undefined,
  ): Object {
    var params = {}

    if (pageIndex !== 0) {
      params['page'] = pageIndex
    }
    if (this.searchInput !== '') {
      params['search'] = this.searchInput
    }
    if (pageSize) {
      if (pageSize !== 10) {
        params['per_page'] = pageSize
      }
    } else {
      if (this.pageSize !== 10) {
        params['per_page'] = this.pageSize
      }
    }
    return params
  }
}
