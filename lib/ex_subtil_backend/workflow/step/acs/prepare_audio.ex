defmodule ExSubtilBackend.Workflow.Step.Acs.PrepareAudio do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobFFmpegEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  require Logger

  @action_name "acs_prepare_audio"

  def launch(workflow) do

    subtitle_languages = get_subtitles_languages(workflow.reference)

    case get_source_files(workflow.jobs, subtitle_languages) do
      [] -> Jobs.create_skipped_job(workflow, @action_name)
      paths -> start_processing_audio(paths, workflow)
    end
  end

  defp start_processing_audio([], _workflow), do: {:ok, "started"}
  defp start_processing_audio([path | paths], workflow) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_subtil_backend, :work_dir) || "/tmp/ftp_francetv"

    filename = Path.basename(path)
    dst_path = work_dir <> "/" <> workflow.reference <> "/acs/"  <> filename

    requirements = Requirements.add_required_paths(path)

    options = %{
      "-codec:a": "pcm_s16le",
      "-y": true,
      "-vn": true,
      "-dn": true,
      "-af": "aresample=resampler=soxr:precision=28:dither_method=shibata",
      "-ar": 16000,
      "-ac": 1
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

  defp get_subtitles_languages(workflow_reference) do
    ExVideoFactory.videos(%{"qid" => workflow_reference})
      |> Map.fetch!(:videos)
      |> List.first
      |> Map.get("text_tracks")
      |> Enum.map(fn(track) ->
        track["code"]
        |> String.downcase
       end)
  end

  defp get_source_files(jobs, _subtitle_languages, result \\ [])
  defp get_source_files([], _subtitle_languages, result), do: result
  defp get_source_files([job | jobs], subtitle_languages, result) do
    result =
      case job.name do
        "audio_decode" ->
          job.params
          |> Map.get("destination", %{})
          |> Map.get("paths")
          |> get_audio_file(subtitle_languages)

        _ -> result
      end

    get_source_files(jobs, subtitle_languages, result)
  end

  defp get_audio_file(_paths, _subtitle_languages, result \\ [])
  defp get_audio_file([], _subtitle_languages, result), do: result
  defp get_audio_file([path | paths], subtitle_languages, result) do
    result =
      cond do
        String.ends_with?(path, "-fra.wav") ->
          if Enum.find(subtitle_languages, fn(lang) -> lang == "fra" end) do
            List.insert_at(result, -1, path)
          end
        String.ends_with?(path, "-qaa.wav") ->
          if Enum.find(subtitle_languages, fn(lang) -> lang == "qaa" end) do
            List.insert_at(result, -1, path)
          end
        String.ends_with?(path, "-qad.wav") ->
          if Enum.find(subtitle_languages, fn(lang) -> lang == "qad" end) do
            List.insert_at(result, -1, path)
          end
        true -> result
      end

    get_audio_file(paths, subtitle_languages, result)
  end
end
