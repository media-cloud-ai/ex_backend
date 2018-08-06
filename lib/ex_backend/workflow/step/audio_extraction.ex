defmodule ExBackend.Workflow.Step.AudioExtraction do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.JobFFmpegEmitter
  alias ExBackend.Workflow.Step.Requirements

  require Logger

  @action_name "audio_extraction"

  def launch(workflow, step) do
    case Map.get(step, "inputs") do
      nil ->
        case get_first_source_file(workflow.jobs) do
          nil -> Jobs.create_skipped_job(workflow, @action_name)
          path -> start_extracting_audio(path, workflow, step)
        end
      inputs ->
        for input <- inputs do
          start_extracting_audio(Map.get(input, "path"), workflow, step)
        end
    end
  end

  defp start_extracting_audio(path, workflow, step) do
    work_dir =
      System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir) ||
        "/tmp/ftp_francetv"

    filename = Path.basename(path, "-standard1.mp4")

    output_extension =
      case Map.get(step, "output_extension") do
        nil -> "-fra.mp4"
        ext -> ext
      end

    dst_path =
      work_dir <>
        "/" <>
        workflow.reference <>
        "_" <> Integer.to_string(workflow.id) <> "/" <> filename <> output_extension

    requirements = Requirements.add_required_paths(path)

    options =
      case Map.get(step, "parameters") do
        nil ->
          %{
            codec_audio: "copy",
            force_overwrite: true,
            disable_video: true,
            disable_data: true
          }
        options -> options
      end

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
    ExBackend.Workflow.Step.FtpDownload.get_jobs_destination_paths(jobs)
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
