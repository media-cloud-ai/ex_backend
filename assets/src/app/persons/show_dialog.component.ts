import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material'
import {Person} from '../models/person'

@Component({
  selector: 'person-show-dialog',
  templateUrl: 'show_dialog.component.html',
  styleUrls: ['./show_dialog.component.less'],
})

export class PersonShowDialogComponent {
  person: Person
  first_names: string
  nationalities: string

  constructor(
    public dialogRef: MatDialogRef<PersonShowDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any) {

    console.log(data)
    this.person = data.person
    this.first_names = this.person.first_names.join(' ')
    this.nationalities = this.person.nationalities.join(', ')
  }

  onNoClick(): void {
    this.dialogRef.close()
  }
}
