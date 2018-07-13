
import {Component} from '@angular/core';
import {BreakpointObserver, Breakpoints} from '@angular/cdk/layout';
import {Title} from '@angular/platform-browser';
import {Subscription} from 'rxjs';

import {AuthService} from './authentication/auth.service';
import {Application} from './models/application';
import {ApplicationService} from './services/application.service';

@Component({
    selector: 'app-component',
    templateUrl: 'app.component.html',
    styleUrls: [ './app.component.less' ],
})

export class AppComponent {
  loggedIn: boolean;
  menu_opened: boolean = false;
  right_panel_opened: boolean = false;
  username: string;
  application: Application;
  right_administrator: boolean;
  right_technician: boolean;
  right_editor: boolean;

  subIn: Subscription;
  subOut: Subscription;

  left_menu = [
  ]


  constructor(
    public authService: AuthService,
    private applicationService: ApplicationService,
    public breakpointObserver: BreakpointObserver,
    private titleService: Title
  ) {}

  ngOnInit() {
    this.subIn = this.authService.userLoggedIn$.subscribe(
      username => {
        this.loggedIn = true;
        this.username = this.authService.getUsername();
        this.right_administrator = this.authService.hasAdministratorRight();
        this.right_technician = this.authService.hasTechnicianRight();
        this.right_editor = this.authService.hasEditorRight();
        this.menu_opened = !this.breakpointObserver.isMatched('(max-width: 599px)');
        this.updateLeftMenu();
      });
    this.subOut = this.authService.userLoggedOut$.subscribe(
      username => {
        this.loggedIn = false;
        this.menu_opened = false;
        this.right_panel_opened = false;
        this.username = "";
        this.right_administrator = false;
        this.right_technician = false;
        this.right_editor = false;
        this.updateLeftMenu();
      });

    if(this.authService.isLoggedIn) {
      this.loggedIn = true;
      this.username = this.authService.getUsername();
      this.right_administrator = this.authService.hasAdministratorRight();
      this.right_technician = this.authService.hasTechnicianRight();
      this.right_editor = this.authService.hasEditorRight();
      this.menu_opened = !this.breakpointObserver.isMatched('(max-width: 599px)');
      this.updateLeftMenu();
    }

    this.applicationService.get()
    .subscribe(application => {
      this.application = application;
      this.setTitle(application.label);
      this.updateLeftMenu();
    });
  }

  updateLeftMenu() {
    if(this.loggedIn) {
      this.left_menu = [];

      if(this.right_technician) {
        if(this.application && this.application.identifier == "subtil") {
          this.left_menu.push({
            "link": "/catalog",
            "label": "Catalog"
          });
        }
        if(this.application && this.application.identifier == "vidtext") {
          this.left_menu.push({
            "link": "/ingest",
            "label": "Ingest"
          });
        }
        this.left_menu.push({
          "link": "/workflows",
          "label": "Workflows"
        });
        this.left_menu.push({
          "link": "/workers",
          "label": "Workers"
        });
      }

      if(this.right_editor) {
        this.left_menu.push({
          "link": "/people",
          "label": "People"
        });
      }

      if(this.right_administrator) {
        this.left_menu.push({
          "link": "/users",
          "label": "Users"
        });
      }

    } else {
      this.left_menu = [];
    }
  }

  public setTitle(newTitle: string) {
    this.titleService.setTitle(newTitle);
  }

  switchMenu() {
    this.menu_opened = !this.menu_opened;
  }

  openRightPanel() {
    this.right_panel_opened = !this.right_panel_opened;
  }

  logout() {
    this.authService.logout();
  }
}
