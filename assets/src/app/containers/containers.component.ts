
import {Component} from '@angular/core';
import {ActivatedRoute, Router} from '@angular/router';

import {ContainerService} from '../services/container.service';
import {NodeService} from '../services/node.service';
import {ImageService} from '../services/image.service';

import {Container} from '../models/container';
import {NodeConfig} from '../models/node_config';
import {Image} from '../models/image';

@Component({
  selector: 'containers-component',
  templateUrl: 'containers.component.html',
  styleUrls: ['containers.component.less']
})

export class ContainersComponent {
  sub = undefined;

  containers: Container[];

  nodes: NodeConfig[];
  images: Image[];

  selectedNode: NodeConfig;
  selectedWorker: Image;

  constructor(
    private containerService: ContainerService,
    private nodeService: NodeService,
    private imageService: ImageService,
    private route: ActivatedRoute,
    private router: Router
  ) {
  }

  ngOnInit() {

    this.imageService.getImages()
    .subscribe(imagePage => {
      this.images = imagePage.data;
    });
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.getNodes();
        this.getContainers();
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  getNodes(): void {
    this.nodeService.getNodes()
    .subscribe(nodeConfigPage => {
      this.nodes = nodeConfigPage.data;
    });
  }

  getContainers(): void {
    this.containerService.getContainers()
    .subscribe(containerPage => {
      this.containers = containerPage.data;
    });
  }

  addContainer(): void {
    this.containerService.createContainer(
      this.selectedNode,
      this.selectedWorker.id + "-" + Date.now(),
      this.selectedWorker.params)
    .subscribe(container => {
      this.selectedNode = undefined;
      this.selectedWorker = undefined;
      this.getContainers();
    });
  }

  removeContainer(id: string): void {
    this.containerService.removeContainer(id)
    .subscribe(container => {
      this.getContainers();
    });
  }

  private startContainer(id: string): void {
    this.containerService.updateContainer(id, "start")
    .subscribe(container => {
      this.getContainers()
    });
  }

  private stopContainer(id: string): void {
    this.containerService.updateContainer(id, "stop")
    .subscribe(container => {
      var that = this;
      that.getContainers()
    });
  }

  actionContainer(id: string, state: string): void {
    if(state == 'running') {
      this.stopContainer(id);
    } else {
      this.startContainer(id);
    }
  }

}
