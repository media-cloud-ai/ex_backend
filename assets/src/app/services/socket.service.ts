
import { Injectable } from '@angular/core';
import { Observable, Observer } from 'rxjs';
import { Message } from '../models/message';
import { AuthService } from '../authentication/auth.service';
const { Socket } = require('phoenix');

@Injectable()
export class SocketService {
  socket: any;
  channel: any;

  constructor(private authService: AuthService) { }

  public initSocket(): void {
    var token = this.authService.getToken();
    console.log(token);

    this.socket = new Socket("/socket", {params: {userToken: token}});
    // this.socket.onError(() => this.authService.logout())
    // this.socket.onClose(() => this.authService.logout())

    this.socket.connect();
    this.channel = this.socket.channel("notifications:all", {});

    this.channel.join()
      .receive("ok", resp => {
        console.log("Joined successfully", resp);
      })
      .receive("error", resp => {
        console.log("Unable to join", resp);
      });
  }

  public onNewWorkflow(): Observable<Message> {
    return new Observable<Message>(observer => {
      this.channel.on('new_workflow', (data: Message) => observer.next(data));
    });
  }
  public onWorkflowUpdate(workflow_id: number): Observable<Message> {
    return new Observable<Message>(observer => {
      this.channel.on('update_workflow_' + workflow_id, (data: Message) => observer.next(data));
    });
  }
}
