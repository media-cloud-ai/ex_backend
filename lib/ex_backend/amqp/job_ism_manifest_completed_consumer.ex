defmodule ExBackend.Amqp.JobIsmManifestCompletedConsumer do
  require Logger

  alias ExBackend.Jobs
  alias ExBackend.Workflow.Step.Requirements
  alias ExBackend.Workflows

  use ExBackend.Amqp.CommonConsumer, %{
    queue: "job_ism_manifest_completed",
    consumer: &ExBackend.Amqp.JobIsmManifestCompletedConsumer.consume/4
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id, "status" => status, "parameters" => parameters} = payload) do
    Logger.warn("receive #{inspect(payload)}")
    Jobs.Status.set_job_status(job_id, status)

    job = Jobs.get_job!(job_id)

    source_prefix =
      job.workflow_id
      |> Workflows.get_workflow!
      |> ExBackend.Map.get_by_key_or_atom(:parameters, [])
      |> Requirements.get_parameter("source_prefix")
      |> String.replace_prefix("/", "")

    audio_streams = Requirements.get_parameter(parameters, "audio")
    video_streams = Requirements.get_parameter(parameters, "video")
    subtitles_streams = Requirements.get_parameter(parameters, "subtitles")

    ttml_files =
      case subtitles_streams do
        nil ->
          []
        streams ->
          streams
          |> Enum.map(fn path -> String.replace_suffix(path, ".ismt", ".ttml") end)
      end

    files =
      audio_streams ++ video_streams ++ subtitles_streams ++ ttml_files
      |> Enum.map(fn path -> source_prefix <> "/" <> path end)

    Logger.warn("Set as destination files: #{inspect(files)}")

    params =
      job.params
      |> Map.put(:destination, %{paths: files})

    Jobs.update_job(job, %{params: params})

    ExBackend.WorkflowStepManager.check_step_status(%{job_id: job_id})
    Basic.ack(channel, tag)
  end
end
