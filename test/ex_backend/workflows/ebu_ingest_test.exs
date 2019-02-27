defmodule ExBackend.EbuIngestTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep

  require Logger

  setup do
    channel = ExBackend.HelpersTest.get_amqp_connection()
    on_exit fn ->
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_speech_to_text"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get channel, "job_speech_to_text"

      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_gpac"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_gpac"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get channel, "job_gpac"

      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_ffmpeg"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_ffmpeg"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_ffmpeg"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get channel, "job_ffmpeg"

      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_file_system"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_file_system"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get channel, "job_file_system"
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get channel, "job_file_system"
    end
    :ok
  end

  describe "ebu_ingest_workflow" do
    test "test ebu ingest workflow" do
      filename = "/data/input_filename.mp4"

      workflow_params =
        ExBackend.Workflow.Definition.EbuIngest.get_definition("identifier", filename)
        |> Map.put(:reference, filename)

      {:ok, workflow} = Workflows.create_workflow(workflow_params)
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 1)
      ExBackend.HelpersTest.check(workflow.id, "upload_file", 1)

      ExBackend.HelpersTest.complete_jobs(workflow.id, "upload_file")

      # uploaded_file = "/data/" <> (workflow.id |> Integer.to_string()) <> "/input_filename.mp4"

      # wav_extracted_file =
      #   "/data/" <> (workflow.id |> Integer.to_string()) <> "/2_input_filename.mp4.wav"

      # audio_dash_file =
      #   "/data/" <> (workflow.id |> Integer.to_string()) <> "/3_input_filename.mp4.mp4"

      # video_dash_file =
      #   "/data/" <> (workflow.id |> Integer.to_string()) <> "/4_input_filename.mp4-standard5.mp4"

      # webvtt_file =
      #   "/data/" <> (workflow.id |> Integer.to_string()) <> "/2_input_filename.mp4.wav.vtt"

      audio_lang_file =
        "/data/" <> (workflow.id |> Integer.to_string()) <> "/lang/3_input_filename.mp4-eng.mp4"

      manifest_file = "/data/" <> (workflow.id |> Integer.to_string()) <> "/dash/manifest.mpd"

      stored_subtitle_file =
        "/tmp//" <> (workflow.id |> Integer.to_string()) <> "/2_input_filename.mp4-fra.mp4.vtt"

      stored_audio_track_file =
        "/dash/" <>
          (workflow.id |> Integer.to_string()) <> "/3_input_filename.mp4-eng_track1_dashinit.mp4"

      stored_video_track_file =
        "/dash/" <>
          (workflow.id |> Integer.to_string()) <>
          "/4_input_filename.mp4-standard5_track1_dashinit.mp4"

      stored_manifest_file = "/tmp//" <> (workflow.id |> Integer.to_string()) <> "/manifest.mpd"

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

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 5)
      ExBackend.HelpersTest.check(workflow.id, "audio_extraction", 3)

      ExBackend.HelpersTest.complete_jobs(workflow.id, "audio_extraction")


      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 6)
      ExBackend.HelpersTest.check(workflow.id, "speech_to_text", 1)

      ExBackend.HelpersTest.complete_jobs(workflow.id, "speech_to_text")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)

      ExBackend.HelpersTest.check(workflow.id, 7)
      ExBackend.HelpersTest.check(workflow.id, "copy", 2)

      ExBackend.HelpersTest.complete_jobs(workflow.id, "copy")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)

      ExBackend.HelpersTest.check(workflow.id, 9)
      ExBackend.HelpersTest.check(workflow.id, "register", 1)
      ExBackend.HelpersTest.check(workflow.id, "set_language", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "set_language")
      ExBackend.HelpersTest.set_output_files(workflow.id, "set_language", [audio_lang_file])
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)

      ExBackend.HelpersTest.check(workflow.id, 10)
      ExBackend.HelpersTest.check(workflow.id, "generate_dash", 1)

      ExBackend.HelpersTest.set_output_files(workflow.id, "generate_dash", [manifest_file])
      ExBackend.HelpersTest.complete_jobs(workflow.id, "generate_dash")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)

      ExBackend.HelpersTest.check(workflow.id, 11)
      ExBackend.HelpersTest.check(workflow.id, "copy", 3)

      ExBackend.HelpersTest.complete_jobs(workflow.id, "copy")
      {:ok, "completed"} = WorkflowStep.start_next_step(workflow)

      ExBackend.HelpersTest.check(workflow.id, 12)
      ExBackend.HelpersTest.check(workflow.id, "register", 2)

      params =
        ExBackend.Registeries.list_registeries(%{"workflow_id" => workflow.id, "name" => "master"})
        |> Map.get(:data)
        |> List.first()
        |> Map.get(:params)

      assert %{
               "manifests" => [
                 %{"format" => "dash", "paths" => [stored_manifest_file]}
               ],
               "subtitles" => [
                 %{
                   "language" => "eng",
                   "paths" => [stored_subtitle_file],
                   "version" => "Azure STT"
                 }
               ]
             } == params
    end
  end
end
