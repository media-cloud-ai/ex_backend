
import {Component} from '@angular/core';
import {BreakpointObserver, Breakpoints} from '@angular/cdk/layout';

@Component({
    selector: 'app-component',
    templateUrl: 'app.component.html',
    styleUrls: ['./app.component.less'],
})

export class AppComponent {
  menu_opened = true;

  constructor(breakpointObserver: BreakpointObserver) {
    this.menu_opened = !breakpointObserver.isMatched('(max-width: 599px)');
  }

  switchMenu(): void {
    this.menu_opened = !this.menu_opened;
  }
}
