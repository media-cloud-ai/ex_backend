defmodule ExBackend.FrancetvSubtilAcsTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep
  alias ExBackend.Rdf.Converter

  require Logger

  setup do
    channel = ExBackend.HelpersTest.get_amqp_connection()

    on_exit(fn ->
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get(channel, "job_ftp")
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get(channel, "job_ftp")
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get(channel, "job_ftp")

      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get(channel, "job_http")
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get(channel, "job_http")

      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get(channel, "job_rdf")
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get(channel, "job_rdf")

      {:ok, payload, %{delivery_tag: delivery_tag}} = AMQP.Basic.get(channel, "job_file_system")
      AMQP.Basic.ack(channel, delivery_tag)
      assert ExBackend.HelpersTest.validate_message_format(Poison.decode!(payload))
      {:empty, %{cluster_id: ""}} = AMQP.Basic.get(channel, "job_file_system")
    end)

    :ok
  end

  describe "francetv_subtil_acs_workflow" do
    test "bad id" do
      steps =
        ExBackend.Workflow.Definition.FrancetvSubtilAcs.get_definition(
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
      ExBackend.HelpersTest.check(workflow.id, "audio_extraction", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "audio_extraction")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 3)
      ExBackend.HelpersTest.check(workflow.id, "download_http", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "download_http")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 4)
      ExBackend.HelpersTest.check(workflow.id, "acs_synchronize", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "acs_synchronize")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 5)
      ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "upload_ftp")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 6)
      ExBackend.HelpersTest.check(workflow.id, "push_rdf", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "push_rdf")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 7)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 1)
      ExBackend.HelpersTest.check(workflow.id, "download_http", 1)
      ExBackend.HelpersTest.check(workflow.id, "audio_extraction", 1)
      ExBackend.HelpersTest.check(workflow.id, "acs_synchronize", 1)
      ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 1)
      ExBackend.HelpersTest.check(workflow.id, "push_rdf", 1)
      ExBackend.HelpersTest.check(workflow.id, "clean_workspace", 1)

      {:ok, "completed"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 7)
    end
  end
end
