export class NotificationEndpoint {
  id: number
  endpoint_placeholder: string
  endpoint_url: string
  endpoint_credentials?: string
  inserted_at: string
}

export enum NotificationEndpointEventAction {
  Select,
  Save,
}

export class NotificationEndpointEvent {
  action: NotificationEndpointEventAction
  notification_endpoint: NotificationEndpoint

  constructor(
    action: NotificationEndpointEventAction,
    notification_endpoint: NotificationEndpoint,
  ) {
    this.action = action
    this.notification_endpoint = notification_endpoint
  }
}
