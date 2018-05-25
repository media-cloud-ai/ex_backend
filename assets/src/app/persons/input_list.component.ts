
import {Component, Input, Output, EventEmitter} from '@angular/core';

@Component({
  selector: 'input-list-component',
  templateUrl: 'input_list.component.html',
  styleUrls: ['./input_list.component.less'],
})

export class InputListComponent {
  @Input() title: string;
  @Input() items: any;
  @Input() name: string;

  @Output() onChange = new EventEmitter<any>();

  constructor(
  ) {}

  ngOnInit() {
    if(this.items == undefined) {
      this.items = new Array();
    }
  }

  update(): void {
    this.onChange.emit(this.items);
  }

  track(index: any, item: any): any {
    return index;
  }

}
