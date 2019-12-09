
import {Component} from '@angular/core'
import {DeclaredWorkersService} from '../services/declared_workers.service'

@Component({
  selector: 'declared_workers-component',
  templateUrl: 'declared_workers.component.html',
  styleUrls: ['./declared_workers.component.less'],
})

export class DeclaredWorkersComponent {
  workers: any
  loading = true

  constructor(
    private declaredWorkersService: DeclaredWorkersService
  ) {}

  ngOnInit() {
    this.declaredWorkersService.getWorkers()
    .subscribe(response => {
      this.workers = response
      this.loading = false
    })
  }
}
