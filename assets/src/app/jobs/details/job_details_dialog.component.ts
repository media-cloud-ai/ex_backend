import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog'
import {Job} from '../../models/job'
import {WorkerService} from '../../services/worker.service'

@Component({
  selector: 'job_details_dialog',
  templateUrl: 'job_details_dialog.component.html',
  styleUrls: ['./job_details_dialog.component.less'],
})
export class JobDetailsDialogComponent {
  job: Job
  worker_instance_id = ""

  constructor(
    public dialogRef: MatDialogRef<JobDetailsDialogComponent>,
    @Inject(MAT_DIALOG_DATA)
    public data: any,
    private workerService: WorkerService,
   ) {
    this.job = data

    this.workerService.getWorkerStatuses(this.job.id)
      .subscribe(workerStatuses => {
        if(workerStatuses && workerStatuses.data.length > 0) {
          this.worker_instance_id = workerStatuses.data[0].instance_id;
        }
      })
  }

  onClose(): void {
    this.dialogRef.close()
  }
}
