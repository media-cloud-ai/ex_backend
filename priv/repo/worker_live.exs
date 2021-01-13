
groups = [
  "administrator",
  "technician",
  "editor",
]

{:ok, workflow} = StepFlow.Workflows.create_workflow(%{
  schema_version: "1.8",
  identifier: "dev_workflow_for_live_workers",
  label: "Dev Workflow for live workers",
  tags: ["dev"],
  icon: "custom_icon",
  is_live: true,
  version_major: 6,
  version_minor: 5,
  version_micro: 4,
  reference: "some-identifier",
  steps: [],
  parameters: [
  ],
  rights: [
    %{
      action: "view",
      groups: groups
    },
    %{
      action: "create",
      groups: groups
    },
    %{
      action: "retry",
      groups: groups
    },
    %{
      action: "abort",
      groups: groups
    },
    %{
      action: "delete",
      groups: groups
    }
  ]
})

{:ok, job} = StepFlow.Jobs.create_job(%{
  name: "my_live_step",
  step_id: 666,
  parameters: [],
  workflow_id: workflow.id
})

StepFlow.LiveWorkers.create_live_worker(%{
  ips: [
    "127.0.0.1",
    "192.168.1.1"
  ],
  ports: [80, 443],
  instance_id: "12345676890",
  direct_messaging_queue_name: "my_direct_messaging_queue_name",
  job_id: job.id,
})
