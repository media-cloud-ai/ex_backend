defmodule ExBackend.FrancetvSubtilIngestTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep

  require Logger

  describe "francetv_subtil_ingest_workflow" do
    test "bad id" do
      acs_enable = false

      steps = ExBackend.Workflow.Definition.FrancetvSubtilIngest.get_definition(acs_enable)

      workflow_params = %{
        reference: "bad_movie_id",
        flow: steps
      }

      {:ok, workflow} = Workflows.create_workflow(workflow_params)
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)

      upload_job =
        ExBackend.Jobs.list_jobs(%{"job_type" => "download_ftp", "workflow_id" => workflow.id |> Integer.to_string()})
        |> Map.get(:data)
        |> List.first

      {:error, "unable to publish RDF"} = WorkflowStep.start_next_step(workflow)
    end

    test "il etait une fois la vie" do
      acs_enable = false

      steps = ExBackend.Workflow.Definition.FrancetvSubtilIngest.get_definition(acs_enable)

      workflow_params = %{
        reference: "99787afd-ba2d-410f-b03e-66cf2efb3ed5",
        flow: steps
      }

      {:ok, workflow} = Workflows.create_workflow(workflow_params)
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)

      download_jobs =
        ExBackend.Jobs.list_jobs(%{"workflow_id" => workflow.id |> Integer.to_string()})
        |> Map.get(:data)

      assert length(download_jobs) == 5

      for job <- download_jobs do
        ExBackend.Jobs.Status.set_job_status(job.id, "completed")
      end

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)

      all_jobs =
        ExBackend.Jobs.list_jobs(%{"workflow_id" => workflow.id |> Integer.to_string(), "size" => 30})
        |> Map.get(:data)
        # |> IO.inspect

      assert length(all_jobs) == 6

    end
  end
end
