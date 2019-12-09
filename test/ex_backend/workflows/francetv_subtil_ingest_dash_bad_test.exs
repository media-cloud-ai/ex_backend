defmodule ExBackend.FrancetvSubtilIngestDashBadTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep
  require Logger

  setup do
    channel = ExBackend.HelpersTest.get_amqp_connection()

    on_exit(fn ->
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get(channel, "job_ftp")
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get(channel, "job_http")
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get(channel, "job_file_system")
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get(channel, "job_ffmpeg")
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get(channel, "job_gpac")

      ExBackend.HelpersTest.consume_messages(channel, "job_rdf", 1)
    end)

    :ok
  end

  describe "francetv_subtil_ingest_dash_bad_workflow" do
    # test "bad id" do
    #   source_paths = []

    #   ttml_path =
    #     "https://staticftv-a.akamaihd.net/sous-titres/2018/12/09/195355542-5c0cf635d0b53-1544353508.ttml"

    #   workflow_params =
    #     ExBackend.Workflow.Definition.FrancetvSubtilDashIngest.get_definition(
    #       source_paths,
    #       ttml_path
    #     )
    #     |> Map.put(:reference, "bad_movie_id")

    #   {:ok, workflow} = Workflows.create_workflow(workflow_params)

    #   {:ok, "started"} = WorkflowStep.start_next_step(workflow)
    #   ExBackend.HelpersTest.check(workflow.id, 9)

    #   ExBackend.HelpersTest.check(workflow.id, "download_ftp", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "download_http", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "audio_extraction", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "set_language", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "generate_dash", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "push_rdf", 1)
    #   ExBackend.HelpersTest.complete_jobs(workflow.id, "push_rdf")

    #   {:ok, "completed"} = WorkflowStep.start_next_step(workflow)

    #   ExBackend.HelpersTest.check(workflow.id, 10)
    #   ExBackend.HelpersTest.check(workflow.id, "download_ftp", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "download_http", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "audio_extraction", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "set_language", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "generate_dash", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "push_rdf", 1)
    #   ExBackend.HelpersTest.check(workflow.id, "clean_workspace", 1)
    # end
  end
end
