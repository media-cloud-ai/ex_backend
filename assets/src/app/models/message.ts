
import {User} from './user';
import {Action} from './action';

export interface Body {
  workflow_id?: number
}

export interface Message {
  body?: Body;
  from?: User;
  content?: any;
  action?: Action;
  workflow_id?: number;
}
