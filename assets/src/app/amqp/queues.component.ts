import {Component} from '@angular/core';

import {Queue} from '../services/queue';
import {AmqpService} from '../services/amqp.service';

@Component({
  selector: 'amqp-queues',
  templateUrl: 'queues.component.html',
  styleUrls: ['./queues.component.less'],
})

export class QueuesComponent {

  queues: Queue[];

  constructor(
    private amqpService: AmqpService
  ) {}

  ngOnInit() {
    this.getQueues();
  }

  getQueues(): void {
    this.amqpService.getQueues()
    .subscribe(queuePage => {
      if(queuePage){
        this.queues = queuePage.queues;
      }
    });
  }
}
