
import {Component} from '@angular/core';
import {ActivatedRoute, Router} from '@angular/router';

import {ContainersService} from '../services/containers.service';
import {ContainersPage, HostConfig, Host, WorkerContainer} from '../services/containers_page';

@Component({
  selector: 'containers-component',
  templateUrl: 'containers.component.html',
  styleUrls: ['containers.component.less']
})

export class ContainersComponent {
  sub = undefined;

  containersPage: ContainersPage;

  hosts: Host[];
  workerContainers: WorkerContainer[];

  selectedHost: Host;
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
      this.hosts = this.containersService.getHostsFromConfigs(hostsPage.data);
    });
  }

  getContainersForHost(host: Host): void {
    let config = this.containersService.getConfigFromHost(host);
    this.containersService.getContainersForHost(config)
    .subscribe(containersPage => {
      this.containersPage = containersPage;
    });
  }

  getContainers(): void {
    this.containersService.getContainers()
    .subscribe(containersPage => {
      this.containersPage = containersPage;
    });
  }

  updateContainers(): void {
    for (let host of this.hosts) {
      this.getContainersForHost(host);
    }
  }

  addContainer(): void {
    this.containersService.createContainer(
      this.selectedHost,
      this.selectedWorker.name + "-" + Date.now(),
      this.selectedWorker.params)
    .subscribe(response => {
      if(response.message) {
        alert(response.message)
      }
      if(response.warning) {
        alert(response.warning)
      }
      this.selectedHost = undefined;
      this.selectedWorker = undefined;
      this.getContainers();
    });
  }

  removeContainer(id: string, host: HostConfig): void {
    this.containersService.removeContainer(host, id)
    .subscribe(response => {
      this.getContainers();
    });
  }

  private startContainer(id: string, host: HostConfig): void {
    this.containersService.updateContainer(host, id, "start")
    .subscribe(response => {
      this.getContainers()
    });
  }

  private stopContainer(id: string, host: HostConfig): void {
    this.containersService.updateContainer(host, id, "stop")
    .subscribe(response => {
      var that =  this;
      setTimeout(function() {
        that.getContainers()
      }, 500); // wait a bit until the container is really stopped
    });
  }

  updateContainer(id: string, host: HostConfig, state: string): void {
    if(state == 'running') {
      this.stopContainer(id, host);
    } else {
      this.startContainer(id, host);
    }
  }

}
