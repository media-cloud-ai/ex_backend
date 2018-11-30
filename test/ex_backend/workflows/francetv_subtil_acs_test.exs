defmodule ExBackend.FrancetvSubtilAcsTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep
  alias ExBackend.Rdf.Converter

  require Logger

  describe "francetv_subtil_acs_workflow" do
    test "bad id" do
      steps = ExBackend.Workflow.Definition.FrancetvSubtilAcs.get_definition(
        "ftp://source/path.mp4",
        "http://static/source/path.ttml"
      )

      workflow_params = %{
        reference: "666",
        flow: steps
      }

      {:ok, workflow} = Workflows.create_workflow(workflow_params)
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 1)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "download_ftp")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 2)
      ExBackend.HelpersTest.check(workflow.id, "download_http", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "download_http")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 3)
      ExBackend.HelpersTest.check(workflow.id, "push_rdf", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "push_rdf")

      {:ok, "started"} =  WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 4)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 1)
      ExBackend.HelpersTest.check(workflow.id, "download_http", 1)
      ExBackend.HelpersTest.check(workflow.id, "push_rdf", 1)
      ExBackend.HelpersTest.check(workflow.id, "clean_workspace", 1)

      {:ok, "completed"} =  WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 4)
    end
  end
end
