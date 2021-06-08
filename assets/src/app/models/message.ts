
import {User} from './user'
import {Action} from './action'

export interface Body {
  workflow_id?: number
  content?: any
}

export interface FileEntry {
  filename: string
  abs_path: string
  is_dir: boolean
  is_file: boolean
}

export interface Message {
  body?: Body
  from?: User
  content?: any
  action?: Action
  workflow_id?: number
  entries?: FileEntry[]
}
