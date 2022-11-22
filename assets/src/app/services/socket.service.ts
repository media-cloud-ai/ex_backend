import { Injectable } from '@angular/core'
import { Observable, Observer } from 'rxjs'
import { Message } from '../models/message'
import { AuthService } from '../authentication/auth.service'
import { Socket } from 'phoenix'

@Injectable()
export class SocketService {
  socket: any
  channel: any

  constructor(private authService: AuthService) {}

  public initSocket() {
    var token = this.authService.getToken()

    this.socket = new Socket('/socket', { params: { userToken: token } })
    // this.socket.onError(() => this.authService.logout())
    // this.socket.onClose(() => this.authService.logout())

    this.socket.connect()
  }

  public connectToChannel(channel: string) {
    this.channel = this.socket.channel(channel, {})

    this.channel
      .join()
      .receive('ok', (resp) => {
        console.log('Joined successfully', resp)
      })
      .receive('error', (resp) => {
        console.log('Unable to join', resp)
      })
  }

  public sendMessage(topic: string, body: any) {
    this.channel
      .push(topic, { body: body }, 10000)
      .receive('ok', (msg) => console.log('created message', msg))
      .receive('error', (reasons) => console.log('create failed', reasons))
      .receive('timeout', () => console.log('Networking issue...'))
  }

  public onNewWorkflow(): Observable<Message> {
    return new Observable<Message>((observer) => {
      this.channel.on('new_workflow', (data: Message) => observer.next(data))
    })
  }

  public onDeleteWorkflow(): Observable<Message> {
    return new Observable<Message>((observer) => {
      this.channel.on('delete_workflow', (data: Message) => observer.next(data))
    })
  }

  public onWorkflowUpdate(workflow_id: number): Observable<Message> {
    return new Observable<Message>((observer) => {
      this.channel.on('update_workflow_' + workflow_id, (data: Message) =>
        observer.next(data),
      )
    })
  }

  public onWorkersStatusUpdated(): Observable<Message> {
    return new Observable<Message>((observer) => {
      this.channel.on('workers_status_updated', (data: Message) =>
        observer.next(data),
      )
    })
  }

  public onRetryJob(): Observable<Message> {
    return new Observable<Message>((observer) => {
      this.channel.on('retry_job', (data: Message) => observer.next(data))
    })
  }

  public onList(id: string): Observable<Message> {
    return new Observable<Message>((observer) => {
      this.channel.on(id, (data: Message) => observer.next(data))
    })
  }
}
