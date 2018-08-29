
import { Injectable } from '@angular/core'
import { Subject } from 'rxjs'

@Injectable()
export class MouseMoveService {
  mouveMoveSource = new Subject<MouseEvent>()
  mouseMoveEvent = this.mouveMoveSource.asObservable()


  mouveUpSource = new Subject<Event>()
  mouseUpEvent = this.mouveUpSource.asObservable()

  constructor() { }
}
