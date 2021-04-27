
workflow_definition = %{
  schema_version: "1.8",
  identifier: "dev_live_workflow",
  label: "Dev workflow",
  tags: ["dev"],
  icon: "custom_icon",
  is_live: true,
  version_major: 6,
  version_minor: 5,
  version_micro: 4,
  reference: "some-identifier",
  steps: [
    %{
      id: 0,
      name: "my_first_step",
      icon: "step_icon",
      label: "My first step",
      parameters: [
        %{
          id: "source_paths",
          type: "array_of_strings",
          value: [
            "str://120.0.0.1:8000"
          ]
        },
        %{
          id: "destination_filename",
          type: "template",
          default: "{source_path}.wav",
          value: "{source_path}.wav"
        }
      ]
    }
  ],
  parameters: [
  ],
  rights: [
    %{
      action: "view",
      groups: [
        "administrator",
        "technician",
        "editor",
      ]
    },
    %{
      action: "create",
      groups: [
        "administrator",
        "technician",
        "editor",
      ]
    },
    %{
      action: "retry",
      groups: [
        "administrator",
        "technician"
      ]
    },
    %{
      action: "abort",
      groups: ["administrator"]
    },
    %{
      action: "delete",
      groups: ["administrator"]
    }
  ]
}

{:ok, workflow} = StepFlow.Workflows.create_workflow(workflow_definition)

{:ok, "started"} = StepFlow.Step.start_next(workflow)
