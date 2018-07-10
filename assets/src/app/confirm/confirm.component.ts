
import {Component}   from '@angular/core';
import {ActivatedRoute, Router} from '@angular/router';

import {Application} from '../models/application';
import {ApplicationService} from '../services/application.service';
import {UserService} from '../services/user.service';
import {User} from '../models/user';

@Component({
    selector: 'confirm-component',
    templateUrl: 'confirm.component.html',
    styleUrls: ['./confirm.component.less'],
})

export class ConfirmComponent {
  application: Application;
  validating = false;
  validated = false;
  error = false;
  key: string;
  password: string;
  sub = undefined;

  constructor(
    private applicationService: ApplicationService,
    private userService: UserService,
    private route: ActivatedRoute,
    public router: Router
  ) {}

  ngOnInit() {
    this.applicationService.get()
    .subscribe(application => {
      this.application = application;
    });

    this.sub = this.route.queryParams
      .subscribe(params => {
        this.key = params['key'];
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  setPasswordAndValidate() {
    this.validating = true;
    this.error = false;

    this.userService.confirm(this.password, this.key)
    .subscribe(response => {
      this.validating = false;
      if(response) {
        this.validated = true;
      } else {
        this.error = true;
      }
    });
  }

  goToLogin() {
    this.router.navigate(["/"]);
  }
}
