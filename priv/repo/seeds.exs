# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use the command `mix ecto.setup`
#

users = [
  %{email: "technician@media-cloud.ai", password: "technician", rights: ["technician"]},
  %{email: "editor@media-cloud.ai", password: "editor", rights: ["editor"]}
]

for user <- users do
  {:ok, user} = ExBackend.Accounts.create_user(user)
  ExBackend.Accounts.confirm_user(user)
end

admin = ExBackend.Accounts.get_by(%{"email" => "admin@media-cloud.ai"})
ExBackend.Accounts.update_user(admin, %{rights: ["administrator", "technician", "editor"]})

workflow_definition = %{
  schema_version: "1.8",
  identifier: "dev_workflow",
  label: "Dev workflow",
  tags: ["dev"],
  icon: "custom_icon",
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
            "completed.mov",
            "error.mov",
            "processing.mov",
            "queued.mov",
            "retry.mov",
          ]
        },
        %{
          id: "destination_filename",
          type: "template",
          default: "{source_path}.wav",
          value: "{source_path}.wav"
        }
      ]
    },
    %{
      id: 1,
      name: "skipped_step",
      icon: "step_icon",
      label: "My first step",
      parameters: [
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
        "techinician",
        "editor",
      ]
    },
    %{
      action: "create",
      groups: [
        "administrator",
        "techinician",
        "editor",
      ]
    },
    %{
      action: "retry",
      groups: [
        "administrator",
        "techinician"
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

{:ok, "still_processing"} = StepFlow.Step.start_next(workflow)

defmodule Helpers do
  def get_job_id(workflow_id, type, source_path) do
    get_jobs(workflow_id, type)
    |> Enum.filter(fn job ->
      value =
        Enum.filter(job.parameters, fn parameter ->
          Map.get(parameter, "id") == "source_path"
        end)
        |> List.first
        |> Map.get("value")

      value == source_path
    end)
    |> List.first
    |> Map.get(:id)
  end

  def get_jobs(workflow_id, type) do
    StepFlow.Jobs.list_jobs(%{
      "job_type" => type,
      "workflow_id" => workflow_id |> Integer.to_string(),
      "size" => 50
    })
    |> Map.get(:data)
  end
end

Helpers.get_job_id(workflow.id, "my_first_step", "completed.mov")
|> StepFlow.Jobs.Status.set_job_status(:completed)

Helpers.get_job_id(workflow.id, "my_first_step", "error.mov")
|> StepFlow.Jobs.Status.set_job_status(:error, %{message: "this is an error message"})

job_id = Helpers.get_job_id(workflow.id, "my_first_step", "processing.mov")
StepFlow.Progressions.create_progression(%{job_id: job_id, progression: 33, datetime: ~N[2020-01-31 10:05:36], docker_container_id: "unknown"})
