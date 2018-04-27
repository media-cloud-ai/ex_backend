
import {Component, Input} from '@angular/core';
import {Parameter} from '../models/workflow';

@Component({
  selector: 'parameters-component',
  templateUrl: 'parameters.component.html',
  styleUrls: ['./parameters.component.less'],
})

export class ParametersComponent {
  @Input() parameters: Parameter[];

  constructor(
  ) {}
}
