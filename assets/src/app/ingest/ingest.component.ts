
import {Component} from '@angular/core'
import {MatDialog} from '@angular/material'

import {SocketService} from '../services/socket.service'
import {WatcherService} from '../services/watcher.service'
import {WorkflowService} from '../services/workflow.service'

import {FileEntry, Message} from '../models/message'
import {WatcherPage} from '../models/page/watcher_page'

import {StartIngestDialog} from './dialogs/start_ingest.component'

@Component({
  selector: 'ingest-component',
  templateUrl: 'ingest.component.html',
  styleUrls: ['./ingest.component.less'],
})

export class IngestComponent {
  connection: any
  entries: Message
  full_path = []
  watchers: WatcherPage

  constructor(
    private dialog: MatDialog,
    private socketService: SocketService,
    private watcherService: WatcherService,
    private workflowService: WorkflowService,
  ) {}

  ngOnInit() {
    this.watcherService.getWatchers()
    .subscribe(watcherPage => {
      this.watchers = watcherPage
    })

    this.socketService.initSocket()
    this.socketService.connectToChannel('watch:all')

    this.connection = this.socketService.onList('pouet')
    .subscribe((message: Message) => {
      this.entries = message
    })

    this.updateDir()
  }

  updateDir() {
    this.socketService.sendMessage('ls', {'path': this.full_path.join('/')})
  }

  goTo(index: number) {
    this.full_path = this.full_path.slice(0, index)
    this.updateDir()
  }

  ingest(entry: FileEntry) {
    if (entry.is_dir === true) {
      this.full_path.push(entry.filename)
      this.updateDir()
    } else {
      let filename = entry.filename
      let path = this.full_path.join('/') + '/' + filename
      let dialogRef = this.dialog.open(StartIngestDialog, {data: path})

      dialogRef.afterClosed().subscribe(steps => {
        if (steps !== undefined) {
          console.log('Start Ingest !', steps)
          this.workflowService.createWorkflow({reference: filename, flow: {steps: steps}})
          .subscribe(response => {
            console.log(response)
          })
        }
      })
    }
    
  }
}
