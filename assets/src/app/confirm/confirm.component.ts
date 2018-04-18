
import {Component}   from '@angular/core';
import {ActivatedRoute} from '@angular/router';


import {UserService} from '../services/user.service';
import {User} from '../models/user';

@Component({
    selector: 'confirm-component',
    templateUrl: 'confirm.component.html',
    styleUrls: ['./confirm.component.less'],
})

export class ConfirmComponent {
  message: string;
  sub = undefined;

  constructor(
    private userService: UserService,
    private route: ActivatedRoute
  ) {}

  ngOnInit() {
    this.message = "Validating your account."
    this.sub = this.route
      .queryParams
      .subscribe(params => {

        this.userService.confirm(params['key'])
        .subscribe(response => {
          if(response) {
            this.message = response.info.detail;
          } else {
            this.message = "Unable to validate your account"
          }
        });
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }
}
