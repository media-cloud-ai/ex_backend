
import {Component, ViewChild, Input, Output, EventEmitter} from '@angular/core';
import {PageEvent, MatRadioModule} from '@angular/material';
import {Observable} from 'rxjs';

import {Person, Link, Links, LinkLabels} from '../models/person';

import * as moment from 'moment';
import {Moment} from 'moment';

@Component({
  selector: 'person-form-component',
  templateUrl: 'form.component.html',
  styleUrls: ['./form.component.less'],
})

export class PersonFormComponent {

  private _person: Person;

  links: Link[] = [
    { label: LinkLabels.imdb, url: "" },
    { label: LinkLabels.linkedin, url: "" },
    { label: LinkLabels.facebook, url: "" },
  ];

  genders = [
    "Female",
    "Male",
    "Undefined"
  ];

  @Input()
  set person(person: Person) {
    if(person != undefined && person.last_name) {
      this._person = person;
      // console.log("set person:", person);
      this.links = Links.toLinksArray(this.person.links);
    }
  }

  get person(): Person {
    return this._person;
  }

  @Output() change = new EventEmitter<Person>();

  ngOnInit() {
    if(this._person == undefined) {
      this._person = new Person();
    }
  }

  update(): void {
    if(this._person.last_name && this._person.first_names && this._person.gender && this._person.birth_date) {
      console.log("Update", this._person);
      this._person.links = new Links(this.links);
      this.change.emit(this._person);
    }
  }

  track(index: any, item: any): any {
    return index;
  }

}
