defmodule ExBackend.EbuIngestTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.Repo
  alias ExBackend.Workflows.Workflow
  alias ExBackend.WorkflowStep

  require Logger

  describe "ebu_ingest_workflow" do


    def handle_info(
      {:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}},
      channel) do
      IO.inspect(payload)
    end

    def port_format(port) when is_integer(port) do
      Integer.to_string(port)
    end

    def port_format(port) do
      port
    end

    def rabbitmq_connect(queue) do
      hostname = System.get_env("AMQP_HOSTNAME") || Application.get_env(:amqp, :hostname)
      username = System.get_env("AMQP_USERNAME") || Application.get_env(:amqp, :username)
      password = System.get_env("AMQP_PASSWORD") || Application.get_env(:amqp, :password)

      virtual_host =
        System.get_env("AMQP_VHOST") || Application.get_env(:amqp, :virtual_host) || ""

      virtual_host =
        case virtual_host do
          "" -> virtual_host
          _ -> "/" <> virtual_host
        end

      port =
        System.get_env("AMQP_PORT") || Application.get_env(:amqp, :port) ||
          5672
          |> port_format

      url =
        "amqp://" <> username <> ":" <> password <> "@" <> hostname <> ":" <> port <> virtual_host

      Logger.warn("#{__MODULE__}: Connecting with url: #{url}")

      {:ok, connection} = AMQP.Connection.open(url)
      {:ok, channel} = AMQP.Channel.open(connection)
      AMQP.Queue.declare(channel, queue, durable: false)
      Logger.warn("#{__MODULE__}: connected to queue #{queue}")

      {:ok, _consumer_tag} = AMQP.Basic.consume(channel, queue)
      {:ok, conn: connection, chan: channel}
    end

    setup do
      rabbitmq_connect("ffmpeg_jobs")

      on_exit fn ->
        IO.puts "This is invoked once the test is done. Process: #{inspect self()}"
      end
    end

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
        ExBackend.Jobs.list_jobs(%{"job_type" => "upload_file", "workflow_id" => workflow.id |> Integer.to_string()})
        |> Map.get(:data)
        |> List.first

      ExBackend.Jobs.Status.set_job_status(upload_job.id, "completed")
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)

      job =
        ExBackend.Jobs.list_jobs(%{"job_type" => "copy", "workflow_id" => workflow.id |> Integer.to_string()})
        |> Map.get(:data)
        |> List.first

      ExBackend.Jobs.Status.set_job_status(job.id, "completed")
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      job =
        ExBackend.Jobs.list_jobs(%{"job_type" => "audio_extraction", "workflow_id" => workflow.id |> Integer.to_string()})
        |> Map.get(:data)
        |> List.first

      ExBackend.Jobs.Status.set_job_status(job.id, "completed")
      {:ok, "completed"} = WorkflowStep.start_next_step(workflow)
    end
  end
end
