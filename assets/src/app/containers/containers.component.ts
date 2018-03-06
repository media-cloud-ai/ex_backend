
import {Component} from '@angular/core';
import {ActivatedRoute, Router} from '@angular/router';

import {ContainersService} from '../services/containers.service';
import {ContainersPage, HostConfig, WorkerContainer} from '../services/containers_page';

@Component({
  selector: 'containers-component',
  templateUrl: 'containers.component.html',
  styleUrls: ['containers.component.less']
})

export class ContainersComponent {
  sub = undefined;

  containersPage: ContainersPage;

  hosts: HostConfig[];
  workerContainers: WorkerContainer[];

  selectedHost: HostConfig;
  selectedWorker: WorkerContainer;

  constructor(
    private containersService: ContainersService,
    private route: ActivatedRoute,
    private router: Router
  ) {
    this.workerContainers = new Array<WorkerContainer>();
  }

  ngOnInit() {
    let workers_containers = require('./workers/workers_containers.json');
    for(let worker_container of workers_containers.workers) {
      this.workerContainers.push(worker_container);
    }
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
    this.containersService.getHosts()
    .subscribe(hostsPage => {
      this.hosts = hostsPage.data;
    });
  }

  getContainers(): void {
    this.containersService.getContainers()
    .subscribe(containersPage => {
      this.containersPage = containersPage;
    });
  }

  addContainer(): void {
    this.containersService.createContainer(
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
    this.containersService.removeContainer(id)
    .subscribe(container => {
      this.getContainers();
    });
  }

  private startContainer(id: string): void {
    this.containersService.updateContainer(id, "start")
    .subscribe(container => {
      this.getContainers()
    });
  }

  private stopContainer(id: string): void {
    this.containersService.updateContainer(id, "stop")
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
