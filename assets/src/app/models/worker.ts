
export class Worker {
  id: number
}


export class WorkerJobStatus {
  execution_duration?: number
  job_id: number
  status: string
}

export class WorkerSystemInfo {
  docker_container_id: string
  number_of_processors: number
  total_memory: number
  total_swap: number
  used_memory: number
  used_swap: number
}

export class WorkerStatus {
  activity: string
  current_job?: WorkerJobStatus
  description: string
  direct_messaging_queue_name: string
  inserted_at: string
  instance_id: string
  label: string
  queue_name: string
  sdk_version?: string
  short_description?: string
  system_info?: WorkerSystemInfo
  updated_at: string
  version: string
}

export class WorkersStatus {
  total: number
  data: WorkerStatus[]
}
