
import { Injectable } from '@angular/core'
import { Subject } from 'rxjs'

@Injectable()
export class MouseMoveService {
  mouveMoveSource = new Subject<Event>()
  mouseMoveEvent = this.mouveMoveSource.asObservable()

  constructor() { }
}
