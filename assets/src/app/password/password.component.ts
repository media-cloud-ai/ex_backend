import { Component, Input } from '@angular/core'
import { Application } from '../models/application'
import * as PasswordValidator from 'password-validator'

@Component({
  selector: 'app-password',
  templateUrl: './password.component.html',
  styleUrls: ['./password.component.less'],
})
export class PasswordComponent {
  application: Application
  password: string
  error = false
  hide = true
  @Input() check_validity: boolean

  check_password_validity(): boolean {
    const schema = new PasswordValidator()

    // Add password validation rules
    schema
      .is()
      .min(8)
      .has()
      .uppercase()
      .has()
      .lowercase()
      .has()
      .digits()
      .has()
      .symbols()

    if (!schema.validate(this.password)) {
      return false
    }
    return true
  }

  get_password(): string {
    if (this.check_validity) {
      if (!this.check_password_validity()) {
        this.error = true
        return undefined
      }
    }
    this.error = false
    return this.password
  }
}
