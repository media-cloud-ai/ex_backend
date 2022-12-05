import { Component, EventEmitter, Input, Output } from '@angular/core'

import { NotificationEndpointService } from '../../services/notification_endpoint.service'
import { NotificationEndpoint } from '../../models/notification_endpoint'
import { PwdType } from '../../models/pwd_type'
import { MatSnackBar } from '@angular/material/snack-bar'
import { NotificationEndpointsComponent } from './notification_endpoints.component'

@Component({
  selector: 'notification_endpoint-component',
  templateUrl: 'notification_endpoint.component.html',
  styleUrls: ['./notification_endpoint.component.less'],
})
export class NotificationEndpointComponent {
  @Input() data: NotificationEndpoint
  @Output() deleted: EventEmitter<NotificationEndpoint> =
    new EventEmitter<NotificationEndpoint>()
  @Output() changed: EventEmitter<NotificationEndpoint> =
    new EventEmitter<NotificationEndpoint>()

  pwd_type = PwdType.Password
  disabled = true

  constructor(
    private notificationEndpointsComponent: NotificationEndpointsComponent,
    private notificationEndpointService: NotificationEndpointService,
    private snackBar: MatSnackBar,
  ) {}

  mask(mode) {
    if (mode === true) {
      this.pwd_type = PwdType.Password
    } else {
      this.pwd_type = PwdType.Text
    }
  }

  edit(mode) {
    if (mode == true) {
      this.disabled = false
    } else {
      console.log(this.data.endpoint_crendentials)
      console.log(this.data.endpoint_url)
      console.log(this.data.endpoint_placeholder)
      this.disabled = true
      this.notificationEndpointService
        .changeNotificationEndpoint(
          this.data.id,
          this.data.endpoint_placeholder,
          this.data.endpoint_url,
          (this.data.endpoint_crendentials ??= ''),
        )
        .subscribe((_notificationEndpoint) => {
          if (_notificationEndpoint) {
            this.changed.next(this.data)
          } else {
            if (!this.data.endpoint_url || !this.data.endpoint_placeholder) {
              const _snackBarRef = this.snackBar.open(
                'You must not leave Credentials, URL or Label field empty !',
                '',
                {
                  duration: 3000,
                },
              )
            } else {
              const _snackBarRef = this.snackBar.open(
                'Error while editing Credential Credentials, URL or Label.',
                '',
                {
                  duration: 3000,
                },
              )
            }
            this.notificationEndpointsComponent.listNotificationEndpoints()
          }
        })
    }
  }

  delete() {
    this.notificationEndpointService
      .removeNotificationEndpoint(this.data.endpoint_placeholder)
      .subscribe((_notificationEndpoint) => {
        this.deleted.next(this.data)
      })
  }
}
