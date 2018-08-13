
import {Component, Input} from '@angular/core';

import {User} from '../models/user';

import * as moment from 'moment';

@Component({
  selector: 'user-component',
  templateUrl: 'user.component.html',
  styleUrls: ['./user.component.less'],
})

export class UserComponent {
  @Input() user: User;

  diff: any;
  expired = false;

  constructor() {}

  ngOnInit() {
    var inserted = moment(this.user.inserted_at);
    var now = moment().add(-moment().utcOffset(), 'minutes');
    this.diff = now.diff(inserted);

    var h = now.diff(inserted, 'hours', true);
    if(h > 4){
      this.expired = true;
    }
  }
}
