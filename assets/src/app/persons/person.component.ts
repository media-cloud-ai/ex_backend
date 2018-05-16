
import {Component, ViewChild} from '@angular/core';
import {PageEvent} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';

import {IMDbService} from '../services/imdb.service';
import {PersonService} from '../services/person.service';
import {Person, IMDbPeople, Link, Links, LinkLabels} from '../models/person';

import * as moment from 'moment';
import {Moment} from 'moment';

@Component({
  selector: 'person-component',
  templateUrl: 'person.component.html',
  styleUrls: ['./person.component.less'],
})

export class PersonComponent {
  person: Person;

  peopleInfo: IMDbPeople;
  peopleInfoLink: Link;
  gettingPeopleInfo: boolean = false;

  error_message : string;

  creation: boolean;
  filled: boolean = false;

  updated: boolean;
  sub = undefined;

  constructor(
    private personService: PersonService,
    private imdbService: IMDbService,
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
          this.person = new Person();
        }

        this.updated = false;
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  setPeopleInfoLink(link: Link): void {
    this.peopleInfoLink = link;
  }

  getPeopleInfo(): void {

    switch (this.peopleInfoLink.label) {
      case LinkLabels.imdb:
        this.gettingPeopleInfo = true;
        this.imdbService.getPeople(this.peopleInfoLink.url)
        .subscribe(response => {
          this.peopleInfo = response;
          if(this.peopleInfo == undefined) {
            this.error_message = "Could not retrieve people information from " + LinkLabels.imdb
          } else {
            this.peopleInfoLink.url = "https://www.imdb.com/name/" + this.peopleInfoLink.url + "/"
            this.prefillPersonForm();
          }
          this.gettingPeopleInfo = false;
        });
        break;

      default:
        this.error_message = "Unsupported link: " + this.peopleInfoLink.label;
        break;
    }
  }

  private prefillPersonForm(): void {
    if(this.peopleInfo == undefined) {
      return;
    }

    let name_elems = this.peopleInfo.name.split(" ");
    this.person.first_names = new Array<string>();

    for(var i = 0; i < name_elems.length - 1; ++i) {
      this.person.first_names.push(name_elems[i]);
    }
    this.person.last_name = name_elems[name_elems.length - 1];

    this.person.birth_date = moment(this.peopleInfo.birth_date).toISOString(true);

    let birth_location_elems = this.peopleInfo.birth_location.split(", ");
    this.person.birth_country = birth_location_elems[birth_location_elems.length - 1];
    this.person.birth_city = birth_location_elems.splice(0, birth_location_elems.length - 1).join(", ");

    this.person.links = new Links([this.peopleInfoLink]);
  }

  setPerson(person: Person): void {
    if(this.person.last_name
    && this.person.first_names
    && this.person.first_names.length > 0
    && this.person.gender
    && this.person.birth_date) {
      this.filled = true;
      this.person = person;
    } else {
      this.filled = false;
    }
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
