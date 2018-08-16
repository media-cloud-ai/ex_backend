
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
  selector: 'workers-component',
  templateUrl: 'workers.component.html',
  styleUrls: ['workers.component.less']
})

export class WorkersComponent {
  containers: Container[]

  nodes: NodeConfig[]
  images: Image[]

  selectedWorker: Image

  constructor(
    private containerService: ContainerService,
    private nodeService: NodeService,
    private imageService: ImageService,
    private route: ActivatedRoute,
    private router: Router,
    private dialog: MatDialog
  ) {
  }

  ngOnInit() {
    this.imageService.getImages()
    .subscribe(imagePage => {
      this.images = imagePage.data
    })

    this.getNodes()
    this.getContainers()
  }

  getNodes() {
    this.nodeService.getNodes()
    .subscribe(nodeConfigPage => {
      this.nodes = nodeConfigPage.data
    })
  }

  addNode() {
    let dialogRef = this.dialog.open(NewNodeDialogComponent)

    dialogRef.afterClosed().subscribe(node => {
      if (node !== undefined) {
        this.getNodes()
      }
    })
  }

  deleteNode(id: number) {
    this.nodeService.deleteNode(id)
    .subscribe(response => {
      this.getNodes()
    })
  }

  getContainers() {
    this.containerService.getContainers()
    .subscribe(containerPage => {
      this.containers = containerPage.data
    })
  }

  addContainer() {
    this.containerService.createContainer(
      this.selectedWorker.node_id,
      Date.now().toString(),
      this.selectedWorker.params)
    .subscribe(container => {
      this.selectedWorker = undefined
      this.getContainers()
    })
  }

  removeContainer(id: string) {
    this.containerService.removeContainer(id)
    .subscribe(container => {
      this.getContainers()
    })
  }

  startContainer(id: string) {
    this.containerService.updateContainer(id, 'start')
    .subscribe(container => {
      this.getContainers()
    })
  }

  stopContainer(id: string) {
    this.containerService.updateContainer(id, 'stop')
    .subscribe(container => {
      var that = this
      that.getContainers()
    })
  }

  actionContainer(id: string, state: string) {
    if (state === 'running') {
      this.stopContainer(id)
    } else {
      this.startContainer(id)
    }
  }
}
