
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

  error_message : string;

  creation: boolean;
  updated: boolean;
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
          // console.log(person_id);
          this.creation = false;
          this.personService.getPerson(person_id)
          .subscribe(response => {
            this.person = response.data;
          });

        } else {
          this.creation = true;
        }

        this.updated = false;
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  createPerson(): void {
    this.error_message = "";

    this.personService.createPerson(this.person)
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

    this.personService.updatePerson(this.person.id, this.person)
    .subscribe(response => {
      console.log(response)
      if(response == undefined) {
        this.error_message = "Unable to update information"
      } else {
        this.router.navigate(['/people']);
      }
    });
  }

  cancel(): void {
    this.router.navigate(['/people']);
  }
}
