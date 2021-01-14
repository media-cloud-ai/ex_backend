
import {Component} from '@angular/core'
import {BreakpointObserver, Breakpoints} from '@angular/cdk/layout'
import {Title} from '@angular/platform-browser'
import {Router} from '@angular/router'
import {Subscription} from 'rxjs'

import {AuthService} from './authentication/auth.service'
import {Application} from './models/application'
import {ApplicationService} from './services/application.service'

@Component({
    selector: 'app-component',
    templateUrl: 'app.component.html',
    styleUrls: [ './app.component.less' ],
})

export class AppComponent {
  loggedIn: boolean
  menu_opened: boolean = false
  right_panel_opened: boolean = false
  username: string
  application: Application
  right_administrator: boolean
  right_technician: boolean
  right_editor: boolean
  right_ftvstudio: boolean

  subIn: Subscription
  subOut: Subscription

  left_menu = [
  ]


  constructor(
    public authService: AuthService,
    private applicationService: ApplicationService,
    public breakpointObserver: BreakpointObserver,
    private titleService: Title,
    private router: Router
  ) {}

  ngOnInit() {
    this.subIn = this.authService.userLoggedIn$.subscribe(
      username => {
        this.loggedIn = true
        this.username = this.authService.getUsername()
        this.right_administrator = this.authService.hasAdministratorRight()
        this.right_technician = this.authService.hasTechnicianRight()
        this.right_editor = this.authService.hasEditorRight()
        this.right_ftvstudio = this.authService.hasFtvStudioRight()
        this.menu_opened = !this.breakpointObserver.isMatched('(max-width: 599px)')
        this.updateLeftMenu()
      })
    this.subOut = this.authService.userLoggedOut$.subscribe(
      username => {
        this.loggedIn = false
        this.menu_opened = false
        this.right_panel_opened = false
        this.username = ''
        this.right_administrator = false
        this.right_technician = false
        this.right_editor = false
        this.right_ftvstudio = false
        this.updateLeftMenu()
      })

    if (this.authService.isLoggedIn) {
      this.loggedIn = true
      this.username = this.authService.getUsername()
      this.right_administrator = this.authService.hasAdministratorRight()
      this.right_technician = this.authService.hasTechnicianRight()
      this.right_editor = this.authService.hasEditorRight()
      this.right_ftvstudio = this.authService.hasFtvStudioRight()
      this.menu_opened = !this.breakpointObserver.isMatched('(max-width: 599px)')
      this.updateLeftMenu()
    }

    this.applicationService.get()
    .subscribe(application => {
      this.application = application
      if (application) {
        this.setTitle(application.label)
      }
      this.updateLeftMenu()
    })
  }

  updateLeftMenu() {
    // console.log(this.loggedIn);
    if (this.loggedIn) {
      this.left_menu = [{
        'link': '/orders',
        'label': 'Commandes'
      },
      {
        'link': '/workflows',
        'label': 'Workflows'
      }]

      if (this.right_technician || this.right_ftvstudio) {
        if (this.application && this.application.identifier === 'subtil') {
          this.left_menu.push({
            'link': '/catalog',
            'label': 'Catalog'
          })
        }
      }

      if (this.application && this.application.identifier === 'vidtext') {
        this.left_menu.push({
          'link': '/ingest',
          'label': 'Ingest'
        })
        if (this.right_editor) {
          this.left_menu.push({
            'link': '/registeries',
            'label': 'Catalog'
          })
        }
      }


      if (this.right_technician) {
        this.left_menu.push({
          'link': '/workers',
          'label': 'Workers'
        })
      }

      if (this.application && this.application.identifier === 'vidtext') {
        if (this.right_technician) {
          this.left_menu.push({
            'link': '/watchers',
            'label': 'Watchers'
          })
        }
      }
      if (this.right_administrator) {
        this.left_menu.push({
          'link': '/credentials',
          'label': 'Credentials'
        })
        this.left_menu.push({
          'link': '/users',
          'label': 'Users'
        })
      }

    } else {
      this.left_menu = []
    }
  }

  public setTitle(newTitle: string) {
    this.titleService.setTitle(newTitle)
  }

  switchMenu() {
    this.menu_opened = !this.menu_opened
  }

  openRightPanel() {
    this.right_panel_opened = !this.right_panel_opened
  }

  documentation() {
    this.router.navigate(['/documentation'])
  }

  declaredWorkers() {
    this.router.navigate(['/declared-workers'])
  }

  logout() {
    this.authService.logout()
  }
}
