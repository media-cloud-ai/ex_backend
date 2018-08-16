import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material'
import {Job} from '../../models/job'

@Component({
  selector: 'job_details_dialog',
  templateUrl: 'job_details_dialog.component.html',
  styleUrls: ['./job_details_dialog.component.less'],
})
export class JobDetailsDialogComponent {

  job: Job
  params = {}

  constructor(public dialogRef: MatDialogRef<JobDetailsDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any) {
    this.job = data
    this.initJobParametersToDisplay()
  }

  private initJobParametersToDisplay(): void {
    for (let param_key in this.job.params) {
      if (param_key.includes('source') ||
        param_key.includes('input')) {
        let paths = this.getParamPaths(this.job.params[param_key])
        this.params['in'] = paths
      }

      if (param_key.includes('destination') ||
        param_key.includes('output')) {
        let paths = this.getParamPaths(this.job.params[param_key])
        this.params['out'] = paths
      }
    }
  }

  private getParamPaths(param: object): string[] {
    if (typeof param === 'string') {
      return [param]
    }

    let paths = new Array<string>()
    if (Array.isArray(param)) {
      for (let p of param) {
        paths = paths.concat(this.getParamPaths(p))
      }
      return paths
    }

    return paths.concat(param['paths'] || param['path'])
  }

  onClose(): void {
    this.dialogRef.close()
  }
}
