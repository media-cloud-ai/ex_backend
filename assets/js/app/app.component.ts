
import {Component} from '@angular/core';

@Component({
    selector: 'app-component',
    templateUrl: 'app.component.html',
    // styleUrls: ['sidenav-overview-example.css'],
    styles: [
      `h1 {
        color: blue;
      }
      a.title:link, a.title:visited {
        text-decoration: none;
        color: #FFF;
      }`
    ]
})

export class AppComponent {
  constructor() {}
}
