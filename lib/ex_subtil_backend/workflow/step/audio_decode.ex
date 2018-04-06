defmodule ExSubtilBackend.Workflow.Step.AudioDecode do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobFFmpegEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  require Logger

  @action_name "audio_decode"

  def launch(workflow) do
    case get_source_files(workflow.jobs) do
      [] -> Jobs.create_skipped_job(workflow, @action_name)
      paths -> start_processing_audio(paths, workflow)
    end
  end

  defp start_processing_audio([], _workflow), do: {:ok, "started"}
  defp start_processing_audio([path | paths], workflow) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_subtil_backend, :work_dir) || "/tmp/ftp_francetv"

    filename = Path.basename(path, ".mp4")
    dst_path = work_dir <> "/" <> workflow.reference <> "/audio/"  <> filename <> ".wav"

    requirements = Requirements.add_required_paths(path)

    options = %{
      "-codec:a": "pcm_s16le",
      "-y": true,
      "-vn": true,
      "-dn": true,
      "-ar": 48000,
      "-ac": 2
    }

    job_params = %{
      name: @action_name,
      workflow_id: workflow.id,
      params: %{
        kind: @action_name,
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

    start_processing_audio(paths, workflow)
  end

  defp get_source_files(jobs, result \\ [])
  defp get_source_files([], result), do: result
  defp get_source_files([job | jobs], result) do
    result =
      case job.name do
        "download_ftp" ->
          job.params
          |> Map.get("destination", %{})
          |> Map.get("path")
          |> get_audio_file(result)

        "audio_extraction" ->
          job.params
          |> Map.get("destination", %{})
          |> Map.get("paths")
          |> get_audio_files(result)

        _ -> result
      end

    get_source_files(jobs, result)
  end

  defp get_audio_files(_paths, result \\ [])
  defp get_audio_files([], result), do: result
  defp get_audio_files([path | paths], result) do
    result = get_audio_file(path, result)
    get_audio_files(paths, result)
  end

  defp get_audio_file(path, result \\ []) do
    cond do
      String.ends_with?(path, "-fra.mp4") -> List.insert_at(result, -1, path)
      String.ends_with?(path, "-qaa.mp4") -> List.insert_at(result, -1, path)
      String.ends_with?(path, "-qad.mp4") -> List.insert_at(result, -1, path)
      true -> result
    end
  end
end
