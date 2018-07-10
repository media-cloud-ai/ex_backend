defmodule ExBackend.Workflow.Step.SetLanguage do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.JobGpacEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "set_language"

  def launch(workflow, _step) do
    case get_source_files(workflow.jobs) do
      [] -> Jobs.create_skipped_job(workflow, @action_name)
      paths -> start_setting_languages(paths, workflow)
    end
  end

  defp start_setting_languages([], _workflow), do: {:ok, "started"}

  defp start_setting_languages([path | paths], workflow) do
    work_dir =
      System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir) ||
        "/tmp/ftp_francetv"

    dst_path =
      work_dir <>
        "/" <>
        workflow.reference <>
        "_" <> Integer.to_string(workflow.id) <> "/lang/" <> Path.basename(path)

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
      String.ends_with?(path, "-fra.mp4") ->
        "fra"

      String.ends_with?(path, "-qaa.mp4") ->
        "qaa"

      String.ends_with?(path, "-qad.mp4") ->
        "qad"

      true ->
        ExVideoFactory.videos(%{"qid" => workflow.reference})
        |> Map.fetch!(:videos)
        |> List.first()
        |> Map.get("text_tracks")
        |> List.first()
        |> Map.get("code")
        |> String.downcase()
    end
  end

  defp get_source_files(jobs) do
    audio_files =
      ExBackend.Workflow.Step.AudioEncode.get_jobs_destination_paths(jobs)
      |> Enum.filter(fn path -> is_audio_file?(path) end)

    audio_files =
      ExBackend.Workflow.Step.AudioExtraction.get_jobs_destination_paths(jobs)
      |> Enum.filter(fn path -> is_audio_file?(path) end)
      |> Enum.reject(fn path -> is_file_already_in_list?(path, audio_files) end)
      |> Enum.concat(audio_files)

    audio_files =
      ExBackend.Workflow.Step.FtpDownload.get_jobs_destination_paths(jobs)
      |> Enum.filter(fn path -> is_audio_file?(path) end)
      |> Enum.reject(fn path -> is_file_already_in_list?(path, audio_files) end)
      |> Enum.concat(audio_files)

    ExBackend.Workflow.Step.TtmlToMp4.get_jobs_destination_paths(jobs)
    |> Enum.concat(audio_files)
  end

  defp is_audio_file?(path) do
    cond do
      String.ends_with?(path, "-fra.mp4") -> true
      String.ends_with?(path, "-qaa.mp4") -> true
      String.ends_with?(path, "-qad.mp4") -> true
      true -> false
    end
  end

  defp is_file_already_in_list?(file_path, paths_list) do
    Enum.any?(paths_list, fn path ->
      Path.basename(file_path) == Path.basename(path)
    end)
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
            path -> List.insert_at(result, -1, path)
          end

        _ ->
          result
      end

    get_jobs_destination_paths(jobs, result)
  end
end
