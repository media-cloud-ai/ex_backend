
import {Component, ViewChild} from '@angular/core'
import {PageEvent} from '@angular/material'
import {ActivatedRoute, Router} from '@angular/router'
import {MatStepper} from '@angular/material/stepper'

import {IMDbService} from '../services/imdb.service'
import {PersonService} from '../services/person.service'
import {Person, IMDbPeople, LinkLabel, Links} from '../models/person'

import * as moment from 'moment'
import {Moment} from 'moment'

@Component({
  selector: 'person-component',
  templateUrl: 'person.component.html',
  styleUrls: ['./person.component.less'],
})

export class PersonComponent {
  person: Person

  gettingPeopleInfo: boolean = false

  error_message : string

  creation: boolean
  filled: boolean = false

  updated: boolean
  sub = undefined

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
        var person_id = +params['id']

        if (person_id >= 0) {
          this.creation = false
          this.personService.getPerson(person_id)
          .subscribe(response => {
            console.log(response)
            this.person = response.data
          })

        } else {
          this.creation = true
          this.person = new Person()
        }

        this.updated = false
      })
  }

  ngOnDestroy() {
    this.sub.unsubscribe()
  }

  addPeopleLink(stepper: MatStepper, links: Links): void {
    this.person.links = links
    stepper.next()
    this.getPeopleInfo()
  }

  getPeopleInfo(): void {
    if (this.person.links.imdb) {
      this.gettingPeopleInfo = true
      this.imdbService.getPeople(this.person.links.imdb)
      .subscribe(response => {
        if (response === undefined) {
          this.error_message = 'Could not retrieve people information from ' + LinkLabel.imdb
        } else {
          this.prefillPersonForm(response)
        }
        this.gettingPeopleInfo = false
      })
    }
  }

  private prefillPersonForm(imdbPeople: IMDbPeople): void {
    if (imdbPeople === undefined) {
      return
    }

    let name_elems = imdbPeople.name.split(' ')
    this.person.first_names = new Array<string>()

    for (var i = 0; i < name_elems.length - 1; ++i) {
      this.person.first_names.push(name_elems[i])
    }
    this.person.last_name = name_elems[name_elems.length - 1]

    this.person.birth_date = moment(imdbPeople.birth_date).toISOString(true)

    let birth_location_elems = imdbPeople.birth_location.split(', ')
    this.person.birth_country = birth_location_elems[birth_location_elems.length - 1]
    this.person.birth_city = birth_location_elems.splice(0, birth_location_elems.length - 1).join(', ')
  }

  setPerson(person: Person): void {
    if (this.person.last_name
    && this.person.first_names
    && this.person.first_names.length > 0
    && this.person.gender
    && this.person.birth_date) {
      this.filled = true
      this.person = person
    } else {
      this.filled = false
    }
  }

  createPerson(): void {
    this.error_message = ''
    this.personService.createPerson(this.person)
    .subscribe(response => {
      console.log(response)
      if (response === undefined) {
        this.error_message = 'Unable to create person'
      } else {
        this.router.navigate(['/people'])
      }
    })
  }

  updatePerson(): void {
    this.error_message = ''

    this.personService.updatePerson(this.person.id, this.person)
    .subscribe(response => {
      console.log(response)
      if (response === undefined) {
        this.error_message = 'Unable to update information'
      } else {
        this.router.navigate(['/people'])
      }
    })
  }

  cancel(): void {
    this.router.navigate(['/people'])
  }
}
