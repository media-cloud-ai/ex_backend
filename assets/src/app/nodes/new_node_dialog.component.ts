import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material'

import {NodeService} from '../services/node.service'
import {NodeConfig} from '../models/node_config'

@Component({
  selector: 'new_node_dialog',
  templateUrl: 'new_node_dialog.component.html',
  styleUrls: ['./new_node_dialog.component.less'],
})
export class NewNodeDialogComponent {

  node = new NodeConfig()
  connected : boolean

  constructor(
    private nodeService: NodeService,
    public dialogRef: MatDialogRef<NewNodeDialogComponent>
  ) {
    this.node.label = 'test'
    this.node.port = 2376
    this.node.hostname = 'https://192.168.99.100'
    this.node.certfile = '/Users/marco/.docker/machine/certs/cert.pem'
    this.node.keyfile = '/Users/marco/.docker/machine/certs/key.pem'
    this.node.ssl_enabled = true
  }

  onNoClick() {
    this.dialogRef.close()
  }

  private getConfig(): NodeConfig {
    var config = new NodeConfig()
    config.label = this.node.label
    config.hostname = this.node.hostname
    config.port = this.node.port

    if (this.node.ssl_enabled) {
      config.certfile = this.node.certfile
      config.keyfile = this.node.keyfile
    }

    return config
  }

  testConnection() {
    this.connected = undefined
    this.nodeService.testConnection(this.getConfig())
    .subscribe(response => {
      if (response === undefined) {
        this.connected = false
      } else {
        this.connected = true
      }
    })
  }

  onClose() {
    this.nodeService.addNode(this.getConfig())
    .subscribe(response => {
      console.log(response)
      if (response === undefined) {
        // this.message = "unabel to create node";
      } else {
        this.dialogRef.close(this.node)
      }
    })
  }
}
