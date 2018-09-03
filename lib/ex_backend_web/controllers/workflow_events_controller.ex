defmodule ExBackendWeb.WorkflowEventsController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize
  alias ExBackend.Workflows
  alias ExBackend.Jobs
  alias ExBackend.Amqp
  require Logger

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:handle])
  plug(:right_technician_check when action in [:handle])

  def handle(conn, %{"workflow_id" => id} = params) do
    workflow = Workflows.get_workflow!(id)

    case params do
      %{"event" => "abort"} ->
        workflow.flow.steps
        |> skip_remaining_steps(workflow)

        ExBackend.Workflow.Step.CleanWorkspace.launch(workflow)

        topic = "update_workflow_" <> Integer.to_string(workflow.id)

        ExBackendWeb.Endpoint.broadcast!("notifications:all", topic, %{
          body: %{workflow_id: workflow.id}
        })

        send_resp(conn, :ok, "")

      %{"event" => "retry", "job_id" => job_id} ->
        Logger.warn("retry job #{job_id}")
        job = Jobs.get_job!(job_id)

        params = %{
          job_id: job.id,
          parameters: job.params
        }

        publish(job.name, job.id, workflow, params)
        send_resp(conn, :ok, "")

      _ ->
        send_resp(conn, 422, "event is not supported")
    end
  end

  defp skip_remaining_steps([], _workflow), do: nil

  defp skip_remaining_steps([step | steps], workflow) do
    case Map.get(step, "name") do
      "clean_workspace" ->
        nil

      _ ->
        case step.status do
          "queued" -> ExBackend.WorkflowStep.skip_step(workflow, step)
          "processing" -> ExBackend.WorkflowStep.skip_step_jobs(workflow, step)
          _ -> nil
        end
    end

    skip_remaining_steps(steps, workflow)
  end

  defp publish("download_ftp", _job_id, _workflow, params) do
    Amqp.JobFtpEmitter.publish_json(params)
  end

  defp publish("upload_ftp", _job_id, _workflow, params) do
    Amqp.JobFtpEmitter.publish_json(params)
  end

  defp publish("download_http", _job_id, _workflow, params) do
    Amqp.JobHttpEmitter.publish_json(params)
  end

  defp publish("acs_prepare_audio", _job_id, _workflow, params) do
    Amqp.JobFFmpegEmitter.publish_json(params)
  end

  defp publish("acs_synchronize", _job_id, _workflow, params) do
    Amqp.JobAcsEmitter.publish_json(params)
  end

  defp publish("copy", _job_id, _workflow, params) do
    Amqp.JobFileSystemEmitter.publish_json(params)
  end

  defp publish("audio_extraction", _job_id, _workflow, params) do
    Amqp.JobFFmpegEmitter.publish_json(params)
  end

  defp publish("push_rdf", job_id, workflow, _params) do
    ExBackend.Workflow.Step.PushRdf.convert_and_submit(workflow)
    |> case do
      {:ok, _} ->
        Jobs.Status.set_job_status(job_id, "completed")
        {:ok, "completed"}

      {:error, message} ->
        Jobs.Status.set_job_status(job_id, "error", %{
          message: "unable to publish RDF: #{message}"
        })
    end
  end

  defp publish(job_name, _job_id, _workflow, _params) do
    Logger.error("unable to restart job for #{job_name}")
  end
end
