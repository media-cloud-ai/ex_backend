import { Injectable } from '@angular/core'
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http'
import { Observable, of } from 'rxjs'
import { catchError, map, tap } from 'rxjs/operators'

import * as moment from 'moment'
import {Moment} from 'moment'

import {PersonPage} from '../models/page/person_page'
import {PersonData} from '../models/page/person_page'
import {Person} from '../models/person'

@Injectable()
export class PersonService {
  private personsUrl = 'api/persons'

  constructor(private http: HttpClient) { }

  getPersons(page: number, per_page: number): Observable<PersonPage> {
    let params = new HttpParams()
    params = params.append('per_page', per_page.toString())
    if (page > 0) {
      params = params.append('page', String(page + 1))
    }

    return this.http.get<PersonPage>(this.personsUrl, {params: params})
      .pipe(
        tap(personsPage => this.log('fetched PersonPage')),
        catchError(this.handleError('getPersons', undefined))
      )
  }

  getPerson(person_id: number): Observable<PersonData> {
    return this.http.get<PersonData>(this.personsUrl + '/' + person_id)
      .pipe(
        tap(personData => this.log('fetched Person')),
        catchError(this.handleError('getPerson', undefined))
      )
  }

  createPerson(person: any): Observable<Person> {
    let params = {
      person: person
    }
    console.log(params)
    return this.http.post<Person>(this.personsUrl, params)
      .pipe(
        tap(personPage => this.log('create Person')),
        catchError(this.handleError('createPerson', undefined))
      )
  }

  updatePerson(person_id: number, person: any): Observable<Person> {
    let params = {
      person: person
    }
    return this.http.put<Person>(this.personsUrl + '/' + person_id, params)
      .pipe(
        tap(personPage => this.log('update Person')),
        catchError(this.handleError('updatePerson', undefined))
      )
  }

  removePerson(person_id: number): Observable<Person> {
    return this.http.delete<Person>(this.personsUrl + '/' + person_id)
      .pipe(
        tap(personPage => this.log('remove Person')),
        catchError(this.handleError('removePerson', undefined))
      )
  }

  private handleError<T> (operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      this.log(`${operation} failed: ${error.message}`)
      return of(result as T)
    }
  }

  private log(message: string) {
    console.log('PersonService: ' + message)
  }
}
