import { Component } from '@angular/core'
import { interval, Subscription } from 'rxjs'

import { AmqpService } from '../services/amqp.service'
import { Queue } from '../models/queue'

@Component({
  selector: 'amqp-queues',
  templateUrl: 'queues.component.html',
  styleUrls: ['./queues.component.less'],
})
export class QueuesComponent {
  queues: Queue[]
  updaterSub: Subscription

  constructor(private amqpService: AmqpService) {}

  ngOnInit() {
    this.getQueues()

    const updater = interval(60_000)
    this.updaterSub = updater.subscribe((n) => this.getQueues())
  }

  ngOnDestroy() {
    this.updaterSub.unsubscribe()
  }

  getQueues(): void {
    this.amqpService.getQueues().subscribe((queuePage) => {
      if (queuePage) {
        var all_queues = []
        queuePage.queues.forEach(function (queue) {
          if (
            !queue.name.includes('direct_messaging_') &&
            (queue.messages_unacknowledged > 0 ||
              queue.messages - queue.messages_unacknowledged > 0)
          ) {
            all_queues.push(queue)
          }
        })

        this.queues = all_queues
      }
    })
  }
}
