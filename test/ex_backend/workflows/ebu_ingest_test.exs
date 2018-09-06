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
      ExBackend.HelpersTest.check(workflow.id, 1)
      ExBackend.HelpersTest.check(workflow.id, "upload_file", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "upload_file")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 2)
      ExBackend.HelpersTest.check(workflow.id, "copy", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "copy")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 3)
      ExBackend.HelpersTest.check(workflow.id, "audio_extraction", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "audio_extraction")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 4)
      ExBackend.HelpersTest.check(workflow.id, "audio_extraction", 2)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "audio_extraction")

      {:ok, "completed"} = WorkflowStep.start_next_step(workflow)
    end
  end
end
