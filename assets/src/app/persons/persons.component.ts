
import {Component, ViewChild} from '@angular/core';
import {PageEvent, MatDialog} from '@angular/material';
import {ActivatedRoute, Router} from '@angular/router';

import {PersonService} from '../services/person.service';
import {PersonPage} from '../models/page/person_page';
import {Person} from '../models/person';
import {PersonShowDialogComponent} from './show_dialog.component';

import * as moment from 'moment';

@Component({
  selector: 'persons-component',
  templateUrl: 'persons.component.html',
  styleUrls: ['./persons.component.less'],
})

export class PersonsComponent {
  length = 1000;
  pageSize = 10;
  page = 0;
  sub = undefined;

  pageEvent: PageEvent;
  persons: PersonPage;

  constructor(
    private personService: PersonService,
    private route: ActivatedRoute,
    private router: Router,
    public dialog: MatDialog
  ) {}

  ngOnInit() {
    this.sub = this.route
      .queryParams
      .subscribe(params => {
        this.page = +params['page'] || 0;
        this.getPersons(this.page);
      });
  }

  ngOnDestroy() {
    this.sub.unsubscribe();
  }

  getPersons(index): void {
    this.personService.getPersons(index, this.pageSize)
    .subscribe(personPage => {
      this.persons = personPage;
      if(personPage) {
        this.length = personPage.total;
      } else {
        this.length = 0;
      }
    });
  }

  eventGetPerson(event): void {
    this.router.navigate(['/people'], { queryParams: this.getQueryParamsForPage(event.pageIndex) });
    this.getPersons(event.pageIndex);
  }

  removePerson(person_id): void {
    this.personService.removePerson(person_id)
    .subscribe(response => {
      this.getPersons(this.page);
    });
  }

  newPerson(): void {
    this.router.navigate(['/person']);
  }

  editPerson(person_id): void {
    this.router.navigate(['/person'], { queryParams: {id: person_id} });
  }

  showPerson(person_id): void {
    this.personService.getPerson(person_id)
    .subscribe(response => {
      let dialogRef = this.dialog.open(PersonShowDialogComponent, {data: {"person": response.data}});
    });
  }

  getQueryParamsForPage(pageIndex: number): Object {
    var params = {};
    if(pageIndex != 0) {
      params['page'] = pageIndex;
    }

    return params;
  }
}
