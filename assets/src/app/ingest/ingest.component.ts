
import {Component} from '@angular/core';

import {SocketService} from '../services/socket.service';
import {Message} from '../models/message';

@Component({
  selector: 'ingest-component',
  templateUrl: 'ingest.component.html',
  styleUrls: ['./ingest.component.less'],
})

export class IngestComponent {
  connection: any;
  entries: any;

  constructor(
    private socketService: SocketService,
  ) {}

  ngOnInit() {
    this.socketService.initSocket();
    this.socketService.connectToChannel("watch:all");

    this.connection = this.socketService.onList("pouet")
    .subscribe((message: Message) => {
      console.log(message);
      this.entries = message;
    });

    this.socketService.sendMessage("ls", {"path": "/Users/marco/Movies"});
  }

  ingest(entry: any) {
    console.log(entry);
  }
}
