import { Component, EventEmitter, Input, Output } from '@angular/core'
import { MatSnackBar } from '@angular/material/snack-bar'

import { NotificationTemplateService } from '../../services/notification_template.service'
import {
  NotificationTemplate,
  NotificationTemplateEventAction,
  NotificationTemplateEvent,
} from '../../models/notification_template'
import { NotificationTemplatesComponent } from './notification_templates.component'
import { PwdType } from '../../models/pwd_type'

@Component({
  selector: 'notification_template-component',
  templateUrl: 'notification_template.component.html',
  styleUrls: ['./notification_template.component.less'],
})
export class NotificationTemplateComponent {
  @Input() data: NotificationTemplate
  @Input() selected_notification_template: number
  @Output() deleted: EventEmitter<NotificationTemplate> =
    new EventEmitter<NotificationTemplate>()
  @Output() notificationTemplateChange =
    new EventEmitter<NotificationTemplateEvent>()

  pwd_type = PwdType.Password
  disabled = true

  constructor(
    private notificationTemplatesComponent: NotificationTemplatesComponent,
    private notificationTemplateService: NotificationTemplateService,
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
      this.selectNotificationTemplate()
    } else {
      this.disabled = true
      this.saveNotificationTemplate()
      this.notificationTemplateService
        .updateNotificationTemplate(
          this.data.template_name,
          this.data.template_headers,
          this.data.template_body,
        )
        .subscribe((_notificationTemplate) => {
          if (!_notificationTemplate) {
            if (!this.data.template_name) {
              const _snackBarRef = this.snackBar.open(
                'You must not leave Name field empty!',
                '',
                {
                  duration: 3000,
                },
              )
            }
            if (!this.data.template_name.trim()) {
              const _snackBarRef = this.snackBar.open(
                'You must not fill Name field with whitespaces!',
                '',
                {
                  duration: 3000,
                },
              )
            }
            this.notificationTemplatesComponent.listNotificationTemplates()
          }
        })
    }
  }

  delete() {
    this.notificationTemplateService
      .removeNotificationTemplate(this.data.template_name)
      .subscribe((_notificationTemplate) => {
        this.deleted.next(this.data)
      })
  }

  selectNotificationTemplate() {
    this.notificationTemplateChange.emit(
      new NotificationTemplateEvent(
        NotificationTemplateEventAction.Select,
        this.data,
      ),
    )
  }

  saveNotificationTemplate() {
    this.notificationTemplateChange.emit(
      new NotificationTemplateEvent(
        NotificationTemplateEventAction.Save,
        this.data,
      ),
    )
  }
}
