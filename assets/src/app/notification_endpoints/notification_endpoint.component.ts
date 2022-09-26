
import {Component, EventEmitter, Input, Output} from '@angular/core'


import {NotificationEndpointService} from '../services/notification_endpoint.service'
import {NotificationEndpoint} from '../models/notification_endpoint'

@Component({
  selector: 'notification_endpoint-component',
  templateUrl: 'notification_endpoint.component.html',
  styleUrls: ['./notification_endpoint.component.less'],
})

export class NotificationEndpointComponent {
  @Input() data: NotificationEndpoint
  @Output() deleted: EventEmitter<NotificationEndpoint> = new EventEmitter<NotificationEndpoint>();

  pwd_type = "password"

  constructor(
    private notificationEndpointService: NotificationEndpointService,
  ) {}

  mask(mode) {
    if(mode === true) {
      this.pwd_type = "text"
    } else {
      this.pwd_type = "password"
    }
  }

  delete() {
    this.notificationEndpointService.removeNotificationEndpoint(this.data.endpoint_placeholder)
    .subscribe(notificationEndpoint => {
      this.deleted.next(this.data)
    })
  }
}
