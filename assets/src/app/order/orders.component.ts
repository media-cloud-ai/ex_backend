
import {Component} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'

// import {OrderService} from '../services/order.service'

@Component({
  selector: 'orders-component',
  templateUrl: 'orders.component.html',
  styleUrls: ['./orders.component.less'],
})

export class OrdersComponent {
  order: any

  constructor(
    private router: Router,
    // private orderService: OrderService
  ) {}

  ngOnInit() {
    // this.order.getOrders()
    // .subscribe(response => {
    //   this.order = response
    // })
  }

  newOrder() {
    this.router.navigate(['/orders/new'])
  }
}
