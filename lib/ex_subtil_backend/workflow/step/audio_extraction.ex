defmodule ExSubtilBackend.Workflow.Step.AudioExtraction do
  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobFFmpegEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  require Logger

  @action_name "audio_extraction"

  def launch(workflow) do
    case get_first_source_file(workflow.jobs) do
      nil -> Jobs.create_skipped_job(workflow, @action_name)
      path -> start_extracting_audio(path, workflow)
    end
  end

  defp start_extracting_audio(path, workflow) do
    work_dir =
      System.get_env("WORK_DIR") || Application.get_env(:ex_subtil_backend, :work_dir) ||
        "/tmp/ftp_francetv"

    filename = Path.basename(path, "-standard1.mp4")
    dst_path = work_dir <> "/" <> workflow.reference <> "/" <> filename <> "-fra.mp4"

    requirements = Requirements.add_required_paths(path)

    options = %{
      "-codec:a": "copy",
      "-y": true,
      "-vn": true,
      "-dn": true
    }

    job_params = %{
      name: @action_name,
      workflow_id: workflow.id,
      params: %{
        requirements: requirements,
        inputs: [
          %{
            path: path,
            options: %{}
          }
        ],
        outputs: [
          %{
            path: dst_path,
            options: options
          }
        ]
      }
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params
    }

    JobFFmpegEmitter.publish_json(params)

    {:ok, "started"}
  end

  defp get_first_source_file(jobs) do
    ExSubtilBackend.Workflow.Step.FtpDownload.get_jobs_destination_paths(jobs)
    |> Enum.find(fn path -> String.ends_with?(path, "-standard1.mp4") end)
  end

  @doc """
  Returns the list of destination paths of this workflow step
  """
  def get_jobs_destination_paths(_jobs, result \\ [])
  def get_jobs_destination_paths([], result), do: result

  def get_jobs_destination_paths([job | jobs], result) do
    result =
      case job.name do
        @action_name ->
          job.params
          |> Map.get("destination", %{})
          |> Map.get("paths")
          |> case do
            nil -> result
            paths -> Enum.concat(paths, result)
          end

        _ ->
          result
      end

    get_jobs_destination_paths(jobs, result)
  end
end
