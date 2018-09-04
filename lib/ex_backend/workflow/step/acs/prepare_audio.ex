defmodule ExBackend.Workflow.Step.Acs.PrepareAudio do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.JobFFmpegEmitter
  alias ExBackend.Workflow.Step.Requirements

  require Logger

  @action_name "acs_prepare_audio"

  def launch(workflow, step) do
    if !is_subtitle_file_present?(workflow.jobs) do
      Jobs.create_skipped_job(workflow, ExBackend.Map.get_by_key_or_atom(step, :id), @action_name)
    else
      subtitle_languages = get_subtitles_languages(workflow.reference)

      case get_source_files(workflow.jobs, subtitle_languages) do
        [] -> Jobs.create_skipped_job(workflow, ExBackend.Map.get_by_key_or_atom(step, :id), @action_name)
        paths -> start_processing_audio(paths, workflow)
      end
    end
  end

  defp start_processing_audio([], _workflow), do: {:ok, "started"}

  defp start_processing_audio([path | paths], workflow) do
    work_dir =
      System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir) ||
        "/tmp/ftp_francetv"

    filename = Path.basename(path)

    dst_path =
      work_dir <>
        "/" <> workflow.reference <> "_" <> Integer.to_string(workflow.id) <> "/acs/" <> filename

    requirements = Requirements.add_required_paths(path)

    options = %{
      codec_audio: "pcm_s16le",
      force_overwrite: true,
      disable_video: true,
      disable_data: true,
      audio_filters: "aresample=resampler=soxr:precision=28:dither_method=shibata",
      audio_sampling_rate: 16000,
      audio_channels: 1
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

    start_processing_audio(paths, workflow)
  end

  defp get_subtitles_languages(workflow_reference) do
    ExVideoFactory.videos(%{"qid" => workflow_reference})
    |> Map.fetch!(:videos)
    |> List.first()
    |> Map.get("text_tracks")
    |> Enum.map(fn track ->
      track["code"]
      |> String.downcase()
    end)
  end

  defp is_subtitle_file_present?(jobs) do
    length(ExBackend.Workflow.Step.HttpDownload.get_jobs_destination_paths(jobs)) > 0
  end

  defp get_source_files(_jobs, []), do: []

  defp get_source_files(jobs, subtitle_languages) do
    ExBackend.Workflow.Step.AudioDecode.get_jobs_destination_paths(jobs)
    |> Enum.filter(fn path ->
      is_audio_file_matching_subtitles?(path, subtitle_languages)
    end)
  end

  defp is_audio_file_matching_subtitles?(path, subtitle_languages) do
    is_audio_file_matching_subtitles_language?(path, subtitle_languages, "fra") ||
      is_audio_file_matching_subtitles_language?(path, subtitle_languages, "qaa") ||
      is_audio_file_matching_subtitles_language?(path, subtitle_languages, "qad")
  end

  defp is_audio_file_matching_subtitles_language?(path, subtitle_languages, language) do
    if String.ends_with?(path, "-" <> language <> ".wav") do
      Enum.any?(subtitle_languages, fn lang -> lang == language end)
    else
      false
    end
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
