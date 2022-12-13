import { Component, EventEmitter, Input, Output } from '@angular/core'
import { MatSnackBar } from '@angular/material/snack-bar'

import { NotificationEndpointService } from '../../services/notification_endpoint.service'
import {
  NotificationEndpoint,
  NotificationEndpointEventAction,
  NotificationEndpointEvent,
} from '../../models/notification_endpoint'
import { NotificationEndpointsComponent } from './notification_endpoints.component'
import { PwdType } from '../../models/pwd_type'

@Component({
  selector: 'notification_endpoint-component',
  templateUrl: 'notification_endpoint.component.html',
  styleUrls: ['./notification_endpoint.component.less'],
})
export class NotificationEndpointComponent {
  @Input() data: NotificationEndpoint
  @Input() selected_notification_endpoint: number
  @Output() deleted: EventEmitter<NotificationEndpoint> =
    new EventEmitter<NotificationEndpoint>()
  @Output() notificationEndpointChange =
    new EventEmitter<NotificationEndpointEvent>()

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

  edit(is_edited) {
    if (is_edited === true) {
      this.disabled = false
      this.selectNotificationEndpoint()
    } else {
      this.disabled = true
      this.saveNotificationEndpoint()
      this.notificationEndpointService
        .changeNotificationEndpoint(
          this.data.id,
          this.data.endpoint_placeholder,
          this.data.endpoint_url,
          (this.data.endpoint_crendentials ??= ''),
        )
        .subscribe((_notificationEndpoint) => {
          if (!_notificationEndpoint) {
            if (!this.data.endpoint_url || !this.data.endpoint_placeholder) {
              const _snackBarRef = this.snackBar.open(
                'You must not leave Credentials, URL or Label field empty!',
                '',
                {
                  duration: 3000,
                },
              )
            }
            if (
              !this.data.endpoint_url.trim() ||
              !this.data.endpoint_placeholder.trim()
            ) {
              const _snackBarRef = this.snackBar.open(
                'You must not fill URL or Label field with whitespaces!',
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

  selectNotificationEndpoint() {
    this.notificationEndpointChange.emit(
      new NotificationEndpointEvent(
        NotificationEndpointEventAction.Select,
        this.data,
      ),
    )
  }

  saveNotificationEndpoint() {
    this.notificationEndpointChange.emit(
      new NotificationEndpointEvent(
        NotificationEndpointEventAction.Save,
        this.data,
      ),
    )
  }
}
