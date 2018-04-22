
import {Component, Input} from '@angular/core';

@Component({
  selector: 'input-list-component',
  templateUrl: 'input_list.component.html',
  styleUrls: ['./input_list.component.less'],
})

export class InputListComponent {
  @Input() items: any;

  constructor(
  ) {}

  ngOnInit() {
  }
}
