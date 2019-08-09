
import {Component} from '@angular/core'
import {ActivatedRoute} from '@angular/router'

// import {OrderService} from '../services/order.service'

@Component({
  selector: 'order-component',
  templateUrl: 'order.component.html',
  styleUrls: ['./order.component.less'],
})

export class OrderComponent {
  is_new_order: boolean = false
  order_id: number

  constructor(
    private route: ActivatedRoute,
    // private orderService: OrderService
  ) {}

  ngOnInit() {
    this.route
      .params.subscribe(params => {
        if(params['id'] == 'new') {
          this.is_new_order = true
        } else {
          this.order_id = params['id']
        }
      })
  }
}
