
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
  sub = undefined;

  containersPage: ContainersPage;

  hosts: Host[];

  constructor(
    private containersService: ContainersService,
    private route: ActivatedRoute,
    private router: Router
  ) {
  }

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
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

}
