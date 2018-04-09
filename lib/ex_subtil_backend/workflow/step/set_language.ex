defmodule ExSubtilBackend.Workflow.Step.SetLanguage do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobGpacEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  @action_name "set_language"

  def launch(workflow, _step) do
    audio_files = get_audio_source_files(workflow.jobs, ["audio_encode", "audio_extraction", "download_ftp"])
    subtitles_files = get_subtitles_source_files(workflow.jobs)

    Enum.concat(audio_files, subtitles_files)
    |> case do
      [] -> Jobs.create_skipped_job(workflow, @action_name)
      paths -> start_setting_languages(paths, workflow)
    end
  end

  defp start_setting_languages([], _workflow), do: {:ok, "started"}
  defp start_setting_languages([path | paths], workflow) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_subtil_backend, :work_dir) || "/tmp/ftp_francetv"

    dst_path = work_dir <> "/" <> workflow.reference <> "/lang/"  <> Path.basename(path)

    language_code = get_file_language(path, workflow)

    options = %{
      "-lang": language_code,
      "-out": dst_path
    }
    requirements = Requirements.add_required_paths(path)
    job_params = %{
      name: @action_name,
      workflow_id: workflow.id,
      params: %{
        kind: @action_name,
        requirements: requirements,
        source: %{
          path: path
        },
        options: options
      }
    }

    {:ok, job} = Jobs.create_job(job_params)
    params = %{
      job_id: job.id,
      parameters: job.params
    }
    JobGpacEmitter.publish_json(params)

    start_setting_languages(paths, workflow)
  end

  defp get_file_language(path, workflow) do
    cond do
      String.ends_with?(path, "-fra.mp4") -> "fra"
      String.ends_with?(path, "-qaa.mp4") -> "qaa"
      String.ends_with?(path, "-qad.mp4") -> "qad"
      true ->
        ExVideoFactory.videos(%{"qid" => workflow.reference})
        |> Map.fetch!(:videos)
        |> List.first
        |> Map.get("text_tracks")
        |> List.first
        |> Map.get("code")
        |> String.downcase
    end
  end

  defp get_audio_source_files(_jobs, _priority_job_names, result \\ [])
  defp get_audio_source_files([], _priority_job_names, result), do: result
  defp get_audio_source_files(_jobs, [], result), do: result
  defp get_audio_source_files(jobs, priority_job_names, result) do

    {jobs, priority_job_names, result} =
      Enum.find(jobs, fn(job) -> job.name == List.first(priority_job_names) end)
      |> case do
          nil ->
            {jobs, List.delete_at(priority_job_names, 0), result}
          job ->
            jobs = List.delete(jobs, job)

            case get_job_destination_files(job) do
              nil -> {jobs, List.delete_at(priority_job_names, 0), result}
              job_dest_path ->
                if Enum.find(result, fn(file) -> Path.basename(file) == Path.basename(job_dest_path) end) do
                  {jobs, List.delete_at(priority_job_names, 0), result}
                else
                  {jobs, priority_job_names, List.insert_at(result, -1, job_dest_path)}
                end
            end
        end

    get_audio_source_files(jobs, priority_job_names, result)
  end

  defp get_job_destination_files(job) do
    case job.name do
      "download_ftp" ->
        job.params
        |> Map.get("destination", %{})
        |> Map.get("path")
        |> filter_audio_files
      _ ->
        job.params
        |> Map.get("destination", %{})
        |> Map.get("paths")
        |> List.first
        |> filter_audio_files
    end
  end

  defp filter_audio_files(path) do
    cond do
      String.ends_with?(path, "-fra.mp4") -> path
      String.ends_with?(path, "-qaa.mp4") -> path
      String.ends_with?(path, "-qad.mp4") -> path
      true -> nil
    end
  end

  defp get_subtitles_source_files(_jobs, result \\ [])
  defp get_subtitles_source_files([], result), do: result
  defp get_subtitles_source_files([job | jobs], result) do
    result =
      case job.name do
        "ttml_to_mp4" ->
          path =
            job.params
            |> Map.get("destination", %{})
            |> Map.get("paths")
          List.insert_at(result, -1, path)

        _ -> result
      end
    get_subtitles_source_files(jobs, result)
  end

end
