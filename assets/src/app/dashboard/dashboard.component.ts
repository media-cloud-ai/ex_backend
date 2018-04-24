
import {Component} from '@angular/core';
import {AuthService}    from '../authentication/auth.service';
import {Subscription}   from 'rxjs/Subscription';

@Component({
    selector: 'dashboard-component',
    templateUrl: 'dashboard.component.html',
})

export class DashboardComponent {
  right_administrator: boolean;
  right_technician: boolean;
  right_editor: boolean;

  subIn: Subscription;
  subOut: Subscription;

  constructor(public authService: AuthService) {}

  ngOnInit() {
    this.subIn = this.authService.userLoggedIn$.subscribe(
      username => {
        this.right_administrator = this.authService.hasAdministratorRight();
        this.right_technician = this.authService.hasTechnicianRight();
        this.right_editor = this.authService.hasEditorRight();
      });
    this.subOut = this.authService.userLoggedOut$.subscribe(
      username => {
        delete this.right_administrator;
        delete this.right_technician;
        delete this.right_editor;
      });

    if(this.authService.isLoggedIn) {
      this.right_administrator = this.authService.hasAdministratorRight();
      this.right_technician = this.authService.hasTechnicianRight();
      this.right_editor = this.authService.hasEditorRight();
    }
  }
}
