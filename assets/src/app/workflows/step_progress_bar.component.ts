
import {Component, Input} from '@angular/core';
import {Step} from '../models/workflow';

@Component({
  selector: 'step-progress-bar-component',
  templateUrl: 'step_progress_bar.component.html',
  styleUrls: ['./step_progress_bar.component.less'],
})

export class StepProgressBarComponent {
  @Input() step: Step;
}
