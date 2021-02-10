
import {Component, ViewChild, Input, Output, EventEmitter} from '@angular/core'
import {PageEvent} from '@angular/material/paginator'
import {MatRadioModule} from '@angular/material/radio'
import {Observable} from 'rxjs'

import {Person} from '../models/person'

import * as moment from 'moment'
import {Moment} from 'moment'

@Component({
  selector: 'person-form-component',
  templateUrl: 'form.component.html',
  styleUrls: ['./form.component.less'],
})

export class PersonFormComponent {

  private _person: Person

  genders = [
    'Female',
    'Male',
    'Unknown'
  ]

  @Input()
  set person(person: Person) {
    if (person !== undefined && person.last_name) {
      this._person = person
    }
  }

  get person(): Person {
    return this._person
  }

  @Output() change = new EventEmitter<Person>()

  ngOnInit() {
    if (this._person === undefined) {
      this._person = new Person()
    }
  }

  update(): void {
    if (this._person.last_name && this._person.first_names && this._person.gender && this._person.birth_date) {
      console.log('Update', this._person)
      this.change.emit(this._person)
    }
  }

  track(index: any, item: any): any {
    return index
  }
}
