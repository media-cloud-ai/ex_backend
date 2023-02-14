export class NotificationTemplate {
  id: number
  template_name: string
  template_headers: string
  template_body: string
  inserted_at: string
}

export enum NotificationTemplateEventAction {
  Select,
  Save,
}

export class NotificationTemplateEvent {
  action: NotificationTemplateEventAction
  notification_template: NotificationTemplate

  constructor(
    action: NotificationTemplateEventAction,
    notification_template: NotificationTemplate,
  ) {
    this.action = action
    this.notification_template = notification_template
  }
}
