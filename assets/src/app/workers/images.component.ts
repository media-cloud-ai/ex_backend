
import {Component} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'
import {MatDialog} from '@angular/material'

import {ContainerService} from '../services/container.service'
import {NodeService} from '../services/node.service'
import {ImageService} from '../services/image.service'
import {NewNodeDialogComponent} from '../nodes/new_node_dialog.component'

import {Container} from '../models/container'
import {NodeConfig} from '../models/node_config'
import {Image} from '../models/image'

@Component({
  selector: 'images-component',
  templateUrl: 'images.component.html',
  styleUrls: ['images.component.less']
})

export class ImagesComponent {
  private sub: any
  private worker_id: any
  images: Image[]

  constructor(
    private route: ActivatedRoute,
    private imageService: ImageService,
  ) {

    this.sub = this.route
      .params.subscribe(params => {
        this.worker_id = +params['id']
        this.getImages()
      })
  }

  getImages() {
    this.imageService.getImages(this.worker_id)
    .subscribe(imagePage => {
      if(imagePage) {
        this.images = imagePage.data
      }
    })
  }

  updateImage(image_id: string) {
    this.imageService.updateImage(this.worker_id, image_id)
    .subscribe(response => {
      console.log(response)
      if(response) {
        this.getImages()
      }
    })
  }

  deleteImage(image_id: string) {
    this.imageService.deleteImage(this.worker_id, image_id)
    .subscribe(response => {
      if(response != "Error") {
        this.getImages()
      }
    })
  }
}
