import { Pipe, PipeTransform } from '@angular/core'
/*
 * Usage:
 *   value | jobStatusIcon
 * Example:
 *   {{ 'completed' | jobStatusIcon }}
 *   formats to: "done"
 */
@Pipe({ name: 'jobStatusIcon' })
export class JobStatusIconPipe implements PipeTransform {
  transform(jobStatus: string): string {
    const allJobStatusIcons = [
      { id: 'completed', name: 'done' },
      { id: 'processing', name: 'refresh' },
      { id: 'error', name: 'clear' },
      { id: 'queued', name: '' },
    ]

    for (let i = allJobStatusIcons.length - 1; i >= 0; i--) {
      if (allJobStatusIcons[i].id === jobStatus) {
        return allJobStatusIcons[i].name
      }
    }
    return jobStatus
  }
}
