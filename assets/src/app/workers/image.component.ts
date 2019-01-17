
import {
  Component,
  EventEmitter,
  Input,
  Output
} from '@angular/core'

import {ContainerService} from '../services/container.service'
import {NodeService} from '../services/node.service'
import {ImageService} from '../services/image.service'
import {NewNodeDialogComponent} from '../nodes/new_node_dialog.component'

import {Container} from '../models/container'
import {NodeConfig} from '../models/node_config'
import {Image} from '../models/image'

@Component({
  selector: 'image-component',
  templateUrl: 'image.component.html',
  styleUrls: ['image.component.less']
})

export class ImageComponent {
  @Input() worker_id: any
  @Input() image: Image
  @Output() refresh: EventEmitter<String> = new EventEmitter<String>();

  constructor(
    private imageService: ImageService,
  ) {}

  updateImage(image_id: string) {
    this.imageService.updateImage(this.worker_id, image_id)
    .subscribe(response => {
      console.log(response)
      if(response) {
        this.refresh.next("updated")
      }
    })
  }

  deleteImage(image_id: string) {
    this.imageService.deleteImage(this.worker_id, image_id)
    .subscribe(response => {
      if(response != "Error") {
        this.refresh.next("deleted")
      }
    })
  }
}
