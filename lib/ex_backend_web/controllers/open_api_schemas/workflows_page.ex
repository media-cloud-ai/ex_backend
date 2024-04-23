defmodule ExBackendWeb.OpenApiSchemas.WorkflowsPage do
  @moduledoc false

  alias ExBackendWeb.OpenApiSchemas.Users.User
  alias OpenApiSpex.Schema
  alias StepFlow.WebController.OpenApiSchemas.Durations.Duration
  alias StepFlow.WebController.OpenApiSchemas.Jobs.Jobs
  alias StepFlow.WebController.OpenApiSchemas.Notifications.NotificationEndpoints
  alias StepFlow.WebController.OpenApiSchemas.Parameters.Parameters
  alias StepFlow.WebController.OpenApiSchemas.Statuses.Status
  alias StepFlow.WebController.OpenApiSchemas.Workflows.Artifacts

  defmodule WorkflowWithDetails do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Workflow with details",
      description: "A Workflow with durations and user details",
      type: :object,
      properties: %{
        artifacts: Artifacts.schema(),
        created_at: %Schema{type: :string, description: "Date of creation"},
        deleted: %Schema{type: :boolean, description: "Is the workflow deleted"},
        id: %Schema{type: :integer, description: "Workflow ID"},
        identifier: %Schema{type: :string, description: "Workflow identifier"},
        is_live: %Schema{type: :boolean, description: "Is the workflow live"},
        jobs: Jobs.schema(),
        notification_hooks: NotificationEndpoints.schema(),
        parameters: Parameters.schema(),
        reference: %Schema{type: :string, description: "Workflow reference"},
        schema_version: %Schema{type: :string, description: "Workflow schema version"},
        status: Status.schema(),
        # steps: Steps.schema(),
        version_major: %Schema{type: :integer, description: "Workflow major version"},
        version_micro: %Schema{type: :integer, description: "Workflow micro version"},
        version_minor: %Schema{type: :integer, description: "Workflow minor version"},
        user_uuid: %Schema{
          type: :string,
          description: "UUID of the user who has created the workflow"
        },
        tags: %Schema{type: :array, description: "List of tags", items: %Schema{type: :string}},
        durations: Duration.schema(),
        user: User.schema()
      },
      example: %{
        "artifacts" => [],
        "created_at" => "2022-10-12T08:12:26",
        "deleted" => false,
        "id" => 5536,
        "identifier" => "my_workflow",
        "is_live" => false,
        "jobs" => [
          %{
            "id" => 174_775,
            "inserted_at" => "2022-10-12T08:12:17",
            "last_worker_instance_id" => "",
            "name" => "job_transfer",
            "params" => [
              %{
                "id" => "source_path",
                "type" => "string",
                "value" => "/data/21313/my_file"
              },
              %{
                "id" => "requirements",
                "type" => "requirements",
                "value" => %{
                  "paths" => []
                }
              },
              %{
                "id" => "destination_paths",
                "type" => "array_of_strings",
                "value" => []
              }
            ],
            "progressions" => [
              %{
                "datetime" => "2022-10-12T08:12:26Z",
                "docker_container_id" => "9cadac8db3f2",
                "id" => 11_434_918,
                "job_id" => 174_775,
                "progression" => 100
              }
            ],
            "status" => [
              %{
                "description" => %{
                  "destination_paths" => [],
                  "execution_duration" => 0.569668866,
                  "job_id" => 174_775,
                  "parameters" => [],
                  "status" => "completed"
                },
                "id" => 266_703,
                "inserted_at" => "2022-10-12T08:12:26",
                "state" => "completed"
              }
            ],
            "step_id" => 5,
            "updated_at" => "2022-10-12T08:12:26",
            "workflow_id" => 21_313
          }
        ],
        "notification_hooks" => [],
        "parameters" => [
          %{
            "id" => "source",
            "type" => "string"
          }
        ],
        "reference" => "My Workflow",
        "schema_version" => "1.9",
        "status" => [
          %{
            "description" => %{},
            "id" => 258_649,
            "inserted_at" => "2022-10-12T08:12:26",
            "state" => "pending"
          }
        ],
        "steps" => [
          %{
            "jobs" => %{
              "completed" => 1,
              "errors" => 0,
              "paused" => 0,
              "processing" => 0,
              "queued" => 0,
              "skipped" => 0,
              "stopped" => 0,
              "total" => 1
            },
            "status" => "completed",
            "icon" => "file_download",
            "id" => 0,
            "label" => "Download source elements",
            "name" => "job_transfer",
            "parameters" => [
              %{
                "id" => "source_paths",
                "type" => "array_of_templates",
                "value" => [
                  "{video_source_filename}"
                ]
              }
            ]
          }
        ],
        "tags" => [
          "my",
          "workflow"
        ],
        "user_uuid" => "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "version_major" => 1,
        "version_micro" => 8,
        "version_minor" => 1,
        "durations" => %{
          "job_id" => nil,
          "order_pending" => 1.0,
          "processing" => 4.0,
          "response_pending" => 0.5,
          "total" => 5.5,
          "workflow_id" => 5536
        },
        "user" => %{
          "access_key_id" => "XXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "confirmed_at" => "2022-10-12T10:42:09.000000Z",
          "email" => "xxxx@xxxxxx.xxx",
          "first_name" => "Xxx",
          "id" => 1,
          "inserted_at" => "2022-10-12T10:42:08",
          "last_name" => "Xxxxxxx",
          "roles" => [
            "administrator"
          ],
          "username" => "xxxxxxxx",
          "uuid" => "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        }
      }
    })
  end

  defmodule WorkflowsPage do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Workflows page",
      description: "A collection of Workflows with durations and user details",
      type: :array,
      items: WorkflowWithDetails.schema()
    })
  end
end
