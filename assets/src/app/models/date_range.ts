import * as moment from 'moment';
import {Moment} from 'moment';


export class DateRange {
  public start: Moment;
  public end: Moment;

  constructor() {
    this.start = undefined;
    this.end = undefined;
  }

  setStartDate(date: Moment): void {
    this.start = date;
    if(this.start){
      this.start.hours(0);
      this.start.minutes(0);
      this.start.seconds(0);
      this.start.milliseconds(0);
    }
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

  clearStart(): void {
    this.start = undefined;
  }

  clearEnd(): void {
    this.end = undefined;
  }
}
