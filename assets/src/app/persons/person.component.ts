
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
  first_names: string[];
  birth_date: Moment;
  birth_city: string;
  birth_country: string;
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
            this.first_names = this.person.first_names;
            this.birth_date = moment(this.person.birth_date);
            this.birth_city = this.person.birth_city,
            this.birth_country = this.person.birth_country,
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
      first_names: this.first_names,
      birth_date: this.birth_date,
      birth_city: this.birth_city,
      birth_country: this.birth_country,
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

    let person = {
      last_name: this.last_name,
      first_names: this.first_names,
      birth_date: this.birth_date,
      birth_city: this.birth_city,
      birth_country: this.birth_country,
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
