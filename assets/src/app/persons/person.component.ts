
import {Component, ViewChild} from '@angular/core';
import {PageEvent} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';

import {PersonService} from '../services/person.service';
import {Person} from '../models/person';

import * as moment from 'moment';
import {Moment} from 'moment';

@Component({
  selector: 'person-component',
  templateUrl: 'person.component.html',
  styleUrls: ['./person.component.less'],
})

export class PersonComponent {
  person: Person;

  last_name: string;
  first_name_1: string;
  first_name_2: string;
  first_name_3: string;
  birth_date: Moment;
  nationalities: any;

  error_message : string;

  edition: boolean;
  sub = undefined;

  constructor(
    private personService: PersonService,
    private route: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        var person_id = +params['id'];
        if(person_id >= 0) {
          this.edition = true;
          console.log(person_id);
          this.personService.getPerson(person_id)
          .subscribe(response => {
            this.person = response.data;
            this.last_name = this.person.last_name;
            this.first_name_1 = this.person.first_names[0];
            this.first_name_2 = this.person.first_names[1];
            this.first_name_3 = this.person.first_names[2];
            this.birth_date = moment(this.person.birthday_date);
            this.nationalities = this.person.nationalities;
          });
        } else {
          this.edition = false;
        }
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  createPerson(): void {
    this.error_message = "";

    let person = {
      last_name: this.last_name,
      first_names: [this.first_name_1, this.first_name_2, this.first_name_3],
      birthday_date: this.birth_date,
      nationalities: this.nationalities,
    }

    this.personService.createPerson(person)
    .subscribe(response => {
      console.log(response)
      if(response == undefined) {
        this.error_message = "Unable to create person"
      } else {
        this.router.navigate(['/people']);
      }
    });
  }

  updatePerson(): void {
    this.error_message = "";

    let first_names = [];
    if(this.first_name_1) {
      first_names.push(this.first_name_1);
      if(this.first_name_2) {
        first_names.push(this.first_name_2);
        if(this.first_name_3) {
          first_names.push(this.first_name_3);
        }
      }
    }

    let person = {
      last_name: this.last_name,
      first_names: first_names,
      birthday_date: this.birth_date,
      nationalities: this.nationalities,
    }

    this.personService.updatePerson(this.person.id, person)
    .subscribe(response => {
      console.log(response)
      if(response == undefined) {
        this.error_message = "Unable to update information"
      } else {
        this.router.navigate(['/people']);
      }
    });
  }
}
