import {Component} from '@angular/core'
import {ActivatedRoute, Router} from '@angular/router'

import {MatDialog} from '@angular/material/dialog'
import {Message} from '../../models/message'
import {AuthService} from '../../authentication/auth.service'
import {SocketService} from '../../services/socket.service'
import {WorkflowService} from '../../services/workflow.service'
import {Workflow, Step} from '../../models/workflow'
import {WorkflowRenderer} from '../../models/workflow_renderer'
import {WorkflowAbortDialogComponent} from '../dialogs/workflow_abort_dialog.component'
import {WorkflowPauseDialogComponent} from '../dialogs/workflow_pause_dialog.component'

@Component({
  selector: 'workflow-details-component',
  templateUrl: 'workflow_details.component.html',
  styleUrls: ['./workflow_details.component.less']
})
export class WorkflowDetailsComponent {
  private sub: any

  workflow_id: number
  workflow: Workflow
  renderer: WorkflowRenderer
  can_abort: boolean = false
  can_stop: boolean = true
  can_pause: boolean = false
  can_resume: boolean = false
  parameters_opened: boolean = false
  notification_hooks_opened: boolean = false
  connection: any
  messages: Message[] = []
  right_abort: boolean = false
  step_focus: Map<number, boolean> = new Map()

  pause_post_action: any;

  constructor(
    private authService: AuthService,
    private socketService: SocketService,
    private workflowService: WorkflowService,
    private route: ActivatedRoute,
    private router: Router,
    public dialog: MatDialog
  ) {}

  ngOnInit() {
    this.sub = this.route
      .params.subscribe(params => {
        this.workflow_id = +params['id']
        this.getWorkflow(this.workflow_id)
      })

    this.socketService.initSocket()
    this.socketService.connectToChannel('notifications:all')

    this.connection = this.socketService.onWorkflowUpdate(this.workflow_id)
      .subscribe((message: Message) => {
        this.getWorkflow(this.workflow_id)
      })

    this.connection = this.socketService.onRetryJob()
      .subscribe((message: Message) => {
        if(message.workflow_id == this.workflow_id) {
          this.getWorkflow(this.workflow_id)
        }
      })
  }

  ngOnDestroy() {
    this.sub.unsubscribe()
  }

  getWorkflow(workflow_id): void {
    this.workflowService.getWorkflow(workflow_id)
    .subscribe(workflow => {
      if (workflow === undefined) {
        this.workflow = undefined
        this.renderer = undefined
        return
      }
      this.workflow = workflow.data
      this.renderer = new WorkflowRenderer(this.workflow.steps)
      this.renderer.setStepFocus(this.step_focus);

      let has_at_least_one_queued_job = this.workflow.steps.some((s) => s['jobs']['queued'] == 1)
      let has_at_least_one_processing_step = this.workflow.steps.some((s) => s['status'] === "processing");
      let has_at_least_one_paused_step = this.workflow.steps.some((s) => s['status'] === "paused");

      this.can_abort = !has_at_least_one_queued_job && has_at_least_one_processing_step
      if (this.can_abort && this.workflow.steps.some((s) => s.name === 'clean_workspace' && s.status !== 'queued')) {
        this.can_abort = false
      }

      let last_step = this.workflow.steps[this.workflow.steps.length - 1];
      let is_last_step_processing = last_step['status'] === "processing";

      this.can_pause = this.can_abort && !has_at_least_one_paused_step && !is_last_step_processing;
      this.can_resume = has_at_least_one_paused_step;

      this.pause_post_action = this.getPausePostAction();

      this.authService.hasAnyRights("workflow::" + this.workflow.identifier, "abort").subscribe(
        response => {
          this.right_abort = response.authorized
      })
    })
  }

  goToVideo(video_id): void {
    this.router.navigate(['/catalog'], { queryParams: {video_id: video_id} })
  }

  getStepsCount(): string {
    let count = 0
    for (let step of this.workflow.steps) {
      if (step.jobs.skipped > 0 ||
         step.jobs.completed > 0 ||
         step.jobs.errors > 0) {
        count++
      }
    }
    return count.toString()
  }

  getTotalSteps(): number {
    return this.workflow.steps.length
  }

  getPausePostAction(): any {
    // Retrieve pause post-action
    if (this.workflow.status.state == "paused") {
      let paused_status =
        this.workflow.jobs
        .filter((job) => job.status.findIndex((status) => status.state == "paused") > -1)
        .flatMap((job) => job.status)
        .find((status) => status.state == "paused" && status.description != undefined)

      if (paused_status) {
        return paused_status.description;
      }
    }
    return undefined;
  }

  toggleParameters() {
    this.parameters_opened = !this.parameters_opened;
  }

  toggleNotificationHooks() {
    this.notification_hooks_opened = !this.notification_hooks_opened;
  }

  pause(workflow_id): void {
    let dialogRef = this.dialog.open(WorkflowPauseDialogComponent, {data: {
      'workflow': this.workflow,
      'message': 'pause'
    }})

    dialogRef.afterClosed().subscribe(user_choice => {
      if (user_choice !== undefined) {
        this.workflowService.sendWorkflowEvent(user_choice.workflow.id, user_choice.event)
          .subscribe(response => {
            console.log(response)
          })
      }
    })
  }

  abort(workflow_id): void {
    let dialogRef = this.dialog.open(WorkflowAbortDialogComponent, {data: {
      'workflow': this.workflow,
      'message': 'abort'
    }})

    dialogRef.afterClosed().subscribe(workflow => {
      if (workflow !== undefined) {
        console.log('Abort workflow!')
        this.workflowService.sendWorkflowEvent(workflow.id, {event: 'abort'})
        .subscribe(response => {
          console.log(response)
        })
      }
    })
  }

  resume(workflow_id): void {
    let dialogRef = this.dialog.open(WorkflowAbortDialogComponent, {data: {
      'workflow': this.workflow,
      'message': 'resume'
    }})

    dialogRef.afterClosed().subscribe(workflow => {
      if (workflow !== undefined) {
        console.log('Resume workflow!')
        this.workflowService.sendWorkflowEvent(workflow.id, {event: 'resume'})
        .subscribe(response => {
          console.log(response)
        })
      }
    })
  }

  stop(workflow_id): void {
    let dialogRef = this.dialog.open(WorkflowAbortDialogComponent, {data: {'workflow': this.workflow}})

    dialogRef.afterClosed().subscribe(workflow => {
      if (workflow !== undefined) {
        console.log('Stop workflow!')
        this.workflowService.sendWorkflowEvent(workflow.id, {event: 'stop'})
        .subscribe(response => {
          console.log(response)
        })
      }
    })
  }

  updateStepInWorkflow(step) {
    this.step_focus.set(step.id, step.focus);
  }
}
