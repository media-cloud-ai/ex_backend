
import {Component} from '@angular/core'
import {ActivatedRoute} from '@angular/router'

@Component({
  selector: 'credentials-component',
  templateUrl: 'credentials.component.html',
  styleUrls: ['./credentials.component.less'],
})

export class CredentialsComponent {

  credentials = {
    "PERFECT_MEMORY_USERNAME": "toto",
    "PERFECT_MEMORY_PASSWORD": "pwd",
  }

  constructor(
    private route: ActivatedRoute,
  ) {}

  ngOnInit() {
  }

}
