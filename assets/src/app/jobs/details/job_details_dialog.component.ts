import {Component, Inject} from '@angular/core'
import {MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog'
import {Router} from '@angular/router'
import {Job} from '../../models/job'
import {JobDurations, JobDuration} from '../../models/statistics/duration'
import {WorkerService} from '../../services/worker.service'
import {StatisticsService} from '../../services/statistics.service'
import {Workflow} from '../../models/workflow'

@Component({
  selector: 'job_details_dialog',
  templateUrl: 'job_details_dialog.component.html',
  styleUrls: ['./job_details_dialog.component.less'],
})
export class JobDetailsDialogComponent {
  job: Job
  workflow: Workflow
  duration: JobDuration

  constructor(
    public dialogRef: MatDialogRef<JobDetailsDialogComponent>,
    @Inject(MAT_DIALOG_DATA)
    public data: any,
    private statisticsService: StatisticsService,
    private router: Router,
   ) {
    this.job = data.job
    this.workflow = data.workflow

    this.statisticsService.getJobDurations(this.job.id)
    .subscribe(response => {
        if(response && response.data.length > 0) {
          this.duration = response.data[0];
        }
      })
  }

  goToWorkers(): void {
    console.log("Got to workers!")
    this.router.navigate(['/workers']);
    this.dialogRef.close();
  }

  onClose(): void {
    this.dialogRef.close()
  }
}
