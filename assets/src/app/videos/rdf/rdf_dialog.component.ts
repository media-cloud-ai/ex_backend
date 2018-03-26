import {Component, Inject} from '@angular/core';
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material';

@Component({
  selector: 'rdf_dialog',
  templateUrl: 'rdf_dialog.component.html',
  styleUrls: ['./rdf_dialog.component.less'],
})
export class RdfDialogComponent {

  content: String = "";

  constructor(
    public dialogRef: MatDialogRef<RdfDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any) {

    console.log(data);
    this.content = data.rdf;
  }

  onNoClick(): void {
    this.dialogRef.close();
  }
}
