import { Component, Inject, ViewChild } from '@angular/core'
import { UntypedFormBuilder } from '@angular/forms'
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog'
import { JsonEditorComponent, JsonEditorOptions } from '@maaxgr/ang-jsoneditor'

@Component({
  selector: 'json_editor_dialog',
  templateUrl: 'json_editor_dialog.component.html',
  styleUrls: ['./json_editor_dialog.component.less'],
})
export class JsonEditorDialogComponent {
  json: string
  editorOptions: JsonEditorOptions
  form

  @ViewChild('editor', { static: false }) editor: JsonEditorComponent

  constructor(
    public dialogRef: MatDialogRef<JsonEditorDialogComponent>,
    public fb: UntypedFormBuilder,
    @Inject(MAT_DIALOG_DATA) public data: any,
  ) {
    this.editorOptions = new JsonEditorOptions()
    this.initEditorOptions()
    if (data.json == undefined) {
      this.json = JSON.parse('{}')
    } else {
      this.json = JSON.parse(data.json)
    }
  }

  ngOnInit() {
    this.form = this.fb.group({
      json_input: [this.json],
    })
  }

  initEditorOptions() {
    this.editorOptions.mode = 'text'
  }

  submit() {
    this.json = JSON.stringify(this.form.value.json_input, null, 2)
    this.dialogRef.close(this.json)
  }
}
