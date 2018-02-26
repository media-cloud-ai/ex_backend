
import {Component} from '@angular/core';
import {ActivatedRoute, Router} from '@angular/router';
import {MatTableModule, MatCardModule} from '@angular/material';

import {ContainersService} from '../services/containers.service';
import {ContainersPage, HostConfig, Host} from '../services/containers_page';

@Component({
  selector: 'containers-component',
  templateUrl: 'containers.component.html',
  styleUrls: ['containers.component.less']
})

export class ContainersComponent {

  containersPages: ContainersPage[];
  displayedColumns = [
    'names',
    'image',
    'state',
    'status',
    'id'
  ];

  hosts: Host[];

  constructor(
    private containersService: ContainersService,
    private route: ActivatedRoute,
    private router: Router
  ) {
    this.containersPages = new Array<ContainersPage>();
    this.getHosts();
  }

  getHosts(): void {
    this.containersService.getHosts()
    .subscribe(hostsPage => {
      this.hosts = this.containersService.getHostsFromConfigs(hostsPage.data);
      this.updateContainers();
    });
  }

  getContainers(host: Host): void {
    let config = this.containersService.getConfigFromHost(host);
    this.containersService.getContainers(config)
    .subscribe(containersPage => {
      containersPage.host = host;
      this.containersPages.push(containersPage);
    });
  }

  updateContainers(): void {
    for (let host of this.hosts) {
      this.getContainers(host);
    }
  }


}

