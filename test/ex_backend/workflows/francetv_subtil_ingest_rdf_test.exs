defmodule ExBackend.FrancetvSubtilIngestRdfTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep
  require Logger

  setup do
    channel = ExBackend.HelpersTest.get_amqp_connection()

    on_exit(fn ->
      ExBackend.HelpersTest.consume_messages(channel, "job_ftp", 3)
      ExBackend.HelpersTest.consume_messages(channel, "job_http", 1)
      ExBackend.HelpersTest.consume_messages(channel, "job_rdf", 1)
      ExBackend.HelpersTest.consume_messages(channel, "job_file_system", 1)
    end)

    :ok
  end

  describe "francetv_subtil_ingest_dash_workflow" do
    test "il etait une fois la vie" do
      workflow_params =
        ExBackend.Workflow.Definition.FrancetvSubtilRdfIngest.get_definition_for_akamai_input(
          ["ftp://source/path.mp4"],
          "http://static/source/path.ttml",
          "/prefix"
        )
        |> Map.put(:reference, "99787afd-ba2d-410f-b03e-66cf2efb3ed5")

      {:ok, _workflow} = Workflows.create_workflow(workflow_params)

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
      ExBackend.HelpersTest.check(workflow.id, 4)
      ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 2)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "upload_ftp")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 5)
      ExBackend.HelpersTest.check(workflow.id, "clean_workspace", 1)

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 6)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 1)
      ExBackend.HelpersTest.check(workflow.id, "download_http", 1)
      ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 2)
      ExBackend.HelpersTest.check(workflow.id, "push_rdf", 1)
      ExBackend.HelpersTest.check(workflow.id, "clean_workspace", 1)

      {:ok, "completed"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 6)
    end
  end
end
