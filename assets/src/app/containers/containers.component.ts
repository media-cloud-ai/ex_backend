
import {Component} from '@angular/core';
import {ActivatedRoute, Router} from '@angular/router';

import {ContainerService} from '../services/container.service';
import {HostService} from '../services/host.service';
import {ImageService} from '../services/image.service';

import {Container} from '../models/container';
import {HostConfig} from '../models/host_config';
import {Image} from '../models/image';

@Component({
  selector: 'containers-component',
  templateUrl: 'containers.component.html',
  styleUrls: ['containers.component.less']
})

export class ContainersComponent {
  sub = undefined;

  containers: Container[];

  hosts: HostConfig[];
  images: Image[];

  selectedHost: HostConfig;
  selectedWorker: Image;

  constructor(
    private containerService: ContainerService,
    private hostService: HostService,
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
        this.getHosts();
        this.getContainers();
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  getHosts(): void {
    this.hostService.getHosts()
    .subscribe(hostConfigPage => {
      this.hosts = hostConfigPage.data;
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
      this.selectedHost,
      this.selectedWorker.name + "-" + Date.now(),
      this.selectedWorker.params)
    .subscribe(container => {
      this.selectedHost = undefined;
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
