defmodule ExBackend.EbuIngestTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep

  require Logger

  describe "ebu_ingest_workflow" do
    test "test ebu ingest workflow" do
      filename = "/data/input_filename.mp4"

      steps = ExBackend.Workflow.Definition.EbuIngest.get_definition("identifier", filename)

      workflow_params = %{
        reference: filename,
        flow: steps
      }

      {:ok, workflow} = Workflows.create_workflow(workflow_params)
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)

      upload_job =
        ExBackend.Jobs.list_jobs(%{
          "job_type" => "upload_file",
          "workflow_id" => workflow.id |> Integer.to_string()
        })
        |> Map.get(:data)
        |> List.first()

      ExBackend.Jobs.Status.set_job_status(upload_job.id, "completed")
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)

      job =
        ExBackend.Jobs.list_jobs(%{
          "job_type" => "copy",
          "workflow_id" => workflow.id |> Integer.to_string()
        })
        |> Map.get(:data)
        |> List.first()

      ExBackend.Jobs.Status.set_job_status(job.id, "completed")
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)

      job =
        ExBackend.Jobs.list_jobs(%{
          "job_type" => "audio_extraction",
          "workflow_id" => workflow.id |> Integer.to_string()
        })
        |> Map.get(:data)
        |> List.first()

      ExBackend.Jobs.Status.set_job_status(job.id, "completed")
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
    end
  end
end
