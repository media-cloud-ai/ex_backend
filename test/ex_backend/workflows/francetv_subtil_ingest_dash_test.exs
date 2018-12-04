defmodule ExBackend.FrancetvSubtilIngestDashTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep
  require Logger

  setup do
    channel = ExBackend.HelpersTest.get_amqp_connection()

    on_exit fn ->
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_ftp"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_ftp"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_ftp"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_ftp"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_ftp"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_ftp"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_ftp"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_ftp"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get channel, "job_ftp"

      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_http"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get channel, "job_http"

      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_ffmpeg"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get channel, "job_ffmpeg"

      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_gpac"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_gpac"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_gpac"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_gpac"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_gpac"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_gpac"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get channel, "job_gpac"

      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_rdf"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get channel, "job_rdf"

      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_file_system"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get channel, "job_file_system"
    end
    :ok
  end

  describe "francetv_subtil_ingest_dash_workflow" do
    test "il etait une fois la vie" do
      steps = ExBackend.Workflow.Definition.FrancetvSubtilDashIngest.get_definition()

      workflow_params = %{
        reference: "99787afd-ba2d-410f-b03e-66cf2efb3ed5",
        flow: steps
      }

      {:ok, workflow} = Workflows.create_workflow(workflow_params)

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 5)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 5)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "download_ftp")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 6)
      ExBackend.HelpersTest.check(workflow.id, "download_http", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "download_http")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 7)
      ExBackend.HelpersTest.check(workflow.id, "audio_extraction", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "audio_extraction")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 9)
      ExBackend.HelpersTest.check(workflow.id, "ttml_to_mp4", 2)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "ttml_to_mp4")
      ExBackend.HelpersTest.set_output_files(workflow.id, "ttml_to_mp4", ["subtitle.mp4"])

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 12)
      ExBackend.HelpersTest.check(workflow.id, "set_language", 3)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "set_language")
      ExBackend.HelpersTest.set_output_files(workflow.id, "set_language", ["subtitle-fra.mp4"])

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 13)
      ExBackend.HelpersTest.check(workflow.id, "generate_dash", 1)
      ExBackend.HelpersTest.set_output_files(workflow.id, "generate_dash", [
        "/tmp/manifest.mpd",
        "/tmp/video_track.mp4",
        "/tmp/audio_track.mp4"
      ])

      ExBackend.HelpersTest.complete_jobs(workflow.id, "generate_dash")
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 16)
      ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 3)

      ExBackend.HelpersTest.complete_jobs(workflow.id, "upload_ftp")
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 17)
      ExBackend.HelpersTest.check(workflow.id, "push_rdf", 1)

      ExBackend.HelpersTest.complete_jobs(workflow.id, "push_rdf")
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 18)
      ExBackend.HelpersTest.check(workflow.id, "clean_workspace", 1)

      ExBackend.HelpersTest.complete_jobs(workflow.id, "clean_workspace")
      {:ok, "completed"} = WorkflowStep.start_next_step(workflow)
    end
  end
end
