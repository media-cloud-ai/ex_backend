import * as moment from 'moment';
import {Moment} from 'moment';


export class DateRange {
  private start: Moment;
  private end: Moment;

  constructor() {

  	this.setStartDate(moment());
  	this.setEndDate(moment());
  }

  setStartDate(date: Moment): void {
  	this.start = date;
  	this.start.hours(0);
  	this.start.minutes(0);
  	this.start.seconds(0);
  	this.start.milliseconds(0);
  }

  setEndDate(date: Moment): void {
  	this.end = date;
  }

  getStart(): Moment {
  	return this.start;
  }

  getEnd(): Moment {
  	return this.end;
  }

}
