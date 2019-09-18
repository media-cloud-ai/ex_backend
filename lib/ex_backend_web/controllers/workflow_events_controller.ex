defmodule ExBackendWeb.WorkflowEventsController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize
  alias ExBackend.Workflows
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
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

        conn
        |> put_status(:ok)
        |> json(%{status: "ok"})

      %{"event" => "retry", "job_id" => job_id} ->
        Logger.warn("retry job #{job_id}")
        job = Jobs.get_job!(job_id)

        params = %{
          job_id: job.id,
          parameters: job.parameters
        }

        case publish(job.name, job, workflow, params) do
          :ok ->
            conn
            |> put_status(:ok)
            |> json(%{status: "ok"})

          _ ->
            conn
            |> put_status(:ok)
            |> json(%{status: "error", message: "unable to publish message"})
        end

      %{"event" => "delete"} ->
        for job <- workflow.jobs do
          Jobs.delete_job(job)
        end

        Workflows.delete_workflow(workflow)

        ExBackendWeb.Endpoint.broadcast!("notifications:all", "delete_workflow", %{
          body: %{workflow_id: workflow.id}
        })

        conn
        |> put_status(:ok)
        |> json(%{status: "ok"})

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

  defp publish("download_ftp", _job, _workflow, params) do
    CommonEmitter.publish_json("job_ftp", params)
  end

  defp publish("upload_ftp", _job, _workflow, params) do
    CommonEmitter.publish_json("job_ftp", params)
  end

  defp publish("download_http", _job, _workflow, params) do
    CommonEmitter.publish_json("job_http", params)
  end

  defp publish("acs_prepare_audio", _job, _workflow, params) do
    CommonEmitter.publish_json("job_ffmpeg", params)
  end

  defp publish("acs_synchronize", _job, _workflow, params) do
    CommonEmitter.publish_json("job_acs", params)
  end

  defp publish("asp_process", _job, _workflow, params) do
    CommonEmitter.publish_json("job_asp", params)
  end

  defp publish("copy", _job, _workflow, params) do
    CommonEmitter.publish_json("job_file_system", params)
  end

  defp publish("audio_extraction", _job, _workflow, params) do
    CommonEmitter.publish_json("job_ffmpeg", params)
  end

  defp publish("speech_to_text", _job, _workflow, params) do
    CommonEmitter.publish_json("job_speech_to_text", params)
  end

  defp publish("push_rdf", _job, _workflow, params) do
    CommonEmitter.publish_json("job_rdf", params)
  end

  defp publish("set_language", _job, _workflow, params) do
    CommonEmitter.publish_json("job_gpac", params)
  end

  defp publish("ttml_to_mp4", _job, _workflow, params) do
    CommonEmitter.publish_json("job_gpac", params)
  end

  defp publish("generate_dash", _job, _workflow, params) do
    CommonEmitter.publish_json("job_gpac", params)
  end

  defp publish("send_notification", job, workflow, params) do
    ExBackend.Workflow.Step.Notification.process_notification(workflow, job, params.parameters)
  end

  defp publish(job_name, _job, _workflow, _params) do
    Logger.error("unable to restart job for #{job_name}")
    :error
  end
end
