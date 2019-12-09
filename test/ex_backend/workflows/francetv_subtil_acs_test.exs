defmodule ExBackend.FrancetvSubtilAcsTest do
  use ExBackendWeb.ConnCase

  alias StepFlow.Workflows
  alias StepFlow.Step

  require Logger

  setup do
    channel = ExBackend.HelpersTest.get_amqp_connection()

    on_exit(fn ->
      ExBackend.HelpersTest.consume_messages(channel, "job_queue_not_found", 7)
    end)

    :ok
  end

  describe "francetv_subtil_acs_workflow" do
    test "bad id" do
      workflow_params =
        ExBackend.Workflow.Definition.FrancetvSubtilAcs.get_definition(
          "ftp://source/path.mp4",
          "http://static/source/path.ttml",
          nil
        )
        |> Map.put(:reference, "666")

      {:ok, workflow} = Workflows.create_workflow(workflow_params)

      {:ok, "started"} = Step.start_next(workflow)
      ExBackend.HelpersTest.check(workflow.id, 1)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "download_ftp")

      {:ok, "started"} = Step.start_next(workflow)
      ExBackend.HelpersTest.check(workflow.id, 2)
      ExBackend.HelpersTest.check(workflow.id, "audio_extraction", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "audio_extraction")

      {:ok, "started"} = Step.start_next(workflow)
      ExBackend.HelpersTest.check(workflow.id, 3)
      ExBackend.HelpersTest.check(workflow.id, "download_http", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "download_http")

      {:ok, "started"} = Step.start_next(workflow)
      ExBackend.HelpersTest.check(workflow.id, 4)
      ExBackend.HelpersTest.check(workflow.id, "acs_synchronize", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "acs_synchronize")

      {:ok, "started"} = Step.start_next(workflow)
      ExBackend.HelpersTest.check(workflow.id, 5)
      ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "upload_ftp")

      {:ok, "started"} = Step.start_next(workflow)
      ExBackend.HelpersTest.check(workflow.id, 6)
      ExBackend.HelpersTest.check(workflow.id, "push_rdf", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "push_rdf")

      {:ok, "started"} = Step.start_next(workflow)
      ExBackend.HelpersTest.check(workflow.id, 7)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 1)
      ExBackend.HelpersTest.check(workflow.id, "download_http", 1)
      ExBackend.HelpersTest.check(workflow.id, "audio_extraction", 1)
      ExBackend.HelpersTest.check(workflow.id, "acs_synchronize", 1)
      ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 1)
      ExBackend.HelpersTest.check(workflow.id, "push_rdf", 1)
      ExBackend.HelpersTest.check(workflow.id, "clean_workspace", 1)

      {:ok, "completed"} = Step.start_next(workflow)
      ExBackend.HelpersTest.check(workflow.id, 7)
    end
  end
end
