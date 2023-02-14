import { Component } from '@angular/core'

import { NotificationTemplateService } from '../../services/notification_template.service'
import {
  NotificationTemplate,
  NotificationTemplateEventAction,
  NotificationTemplateEvent,
} from '../../models/notification_template'
import { MatDialog } from '@angular/material/dialog'
import { JsonEditorDialogComponent } from './dialogs/json_editor_dialog.component'
import { MatSnackBar } from '@angular/material/snack-bar'

@Component({
  selector: 'notification_templates-component',
  templateUrl: 'notification_templates.component.html',
  styleUrls: ['./notification_templates.component.less'],
})
export class NotificationTemplatesComponent {
  notificationTemplates: NotificationTemplate[]

  notification_template: NotificationTemplate
  selected_notification_template_id = undefined

  constructor(
    private notificationTemplateService: NotificationTemplateService,
    public dialog: MatDialog,
    private snackBar: MatSnackBar,
  ) {
    this.notification_template = new NotificationTemplate()
  }

  ngOnInit() {
    this.listNotificationTemplates()
  }

  listNotificationTemplates() {
    this.notificationTemplateService
      .getNotificationTemplates()
      .subscribe((notificationTemplatePage) => {
        this.notificationTemplates = notificationTemplatePage.data.sort(
          (a, b) => a.template_name.localeCompare(b.template_name),
        )
      })
  }

  notificationTemplateHasChanged(event: NotificationTemplateEvent) {
    if (event.action == NotificationTemplateEventAction.Select) {
      this.selected_notification_template_id = event.notification_template.id
    }
    if (event.action == NotificationTemplateEventAction.Save) {
      this.selected_notification_template_id = undefined
      this.notification_template = new NotificationTemplate()
    }
  }

  insert() {
    this.notificationTemplateService
      .createNotificationTemplate(
        this.notification_template.template_name,
        this.notification_template.template_headers,
        this.notification_template.template_body,
      )
      .subscribe((notificationTemplatePage) => {
        if (notificationTemplatePage === undefined) {
          const _snackBarRef = this.snackBar.open(
            'Cannot create this notification template, check if you have\
             the appropriate rights and if the template name is not already used.',
            '',
            {
              duration: 7500,
            },
          )
        } else {
          this.listNotificationTemplates()
          this.notification_template = new NotificationTemplate()
        }
      })
  }

  openJsonEditor(notification_template, type) {
    let dialogRef = undefined

    if (notification_template != undefined) {
      this.notification_template = notification_template
    }
    if (type === 'headers') {
      dialogRef = this.dialog.open(JsonEditorDialogComponent, {
        data: {
          json: this.notification_template.template_headers,
        },
      })

      dialogRef.afterClosed().subscribe((json_response) => {
        if (json_response != undefined) {
          this.notification_template.template_headers = json_response
        }
      })
    } else {
      dialogRef = this.dialog.open(JsonEditorDialogComponent, {
        data: {
          json: this.notification_template.template_body,
        },
      })

      dialogRef.afterClosed().subscribe((json_response) => {
        if (json_response != undefined) {
          this.notification_template.template_body = json_response
        }
      })
    }
  }
}
