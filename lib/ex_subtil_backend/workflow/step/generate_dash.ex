defmodule ExSubtilBackend.Workflow.Step.GenerateDash do
  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobGpacEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  require Logger

  @action_name "generate_dash"

  def launch(workflow, step) do
    case build_step_parameters(workflow, step) do
      {:skipped, nil} ->
        Jobs.create_skipped_job(workflow, @action_name)

      {:ok, job_params} ->
        {:ok, job} = Jobs.create_job(job_params)

        params = %{
          job_id: job.id,
          parameters: job.params
        }

        JobGpacEmitter.publish_json(params)

      something_else ->
        Logger.error(
          "#{__MODULE__}: unable to match result of build_step_parameters to #{
            inspect(something_else)
          }"
        )

        {:error, something_else}
    end
  end

  def build_step_parameters(workflow, step) do
    source_file_paths =
      get_source_files(workflow.jobs)
      |> Enum.sort()

    formatted_source_paths = get_formatted_source_paths(source_file_paths)

    case formatted_source_paths do
      [] ->
        {:skipped, nil}

      source_track_paths ->
        source_paths =
          source_track_paths
          |> Enum.map(fn path -> String.replace(path, ~r/\.mp4#.*/, ".mp4") end)

        work_dir =
          System.get_env("WORK_DIR") || Application.get_env(:ex_subtil_backend, :work_dir) ||
            "/tmp/ftp_francetv"

        options = %{
          "-out":
            work_dir <>
              "/dash/" <>
              workflow.reference <> "_" <> Integer.to_string(workflow.id) <> "/manifest.mpd",
          "-profile": "onDemand",
          "-rap": true,
          "-url-template": true
        }

        options =
          Map.get(step, "parameters", [])
          |> build_gpac_parameters(options)

        requirements = Requirements.add_required_paths(source_paths)

        {
          :ok,
          %{
            name: @action_name,
            workflow_id: workflow.id,
            params: %{
              kind: @action_name,
              requirements: requirements,
              source: %{
                paths: source_track_paths
              },
              options: options
            }
          }
        }
    end
  end

  defp get_formatted_source_paths(_paths, _audio_index \\ 1, result \\ [])
  defp get_formatted_source_paths([], _audio_index, result), do: result

  defp get_formatted_source_paths([path | paths], audio_index, result) do
    {result, audio_index} =
      case get_quality(path) do
        nil ->
          {result, audio_index}

        "fra" ->
          audio_path = path <> "#audio:id=a" <> Integer.to_string(audio_index)
          result = List.insert_at(result, -1, audio_path)
          {result, audio_index + 1}

        "qad" ->
          audio_path = path <> "#audio:id=a" <> Integer.to_string(audio_index)
          result = List.insert_at(result, -1, audio_path)
          {result, audio_index + 1}

        "qaa" ->
          audio_path = path <> "#audio:id=a" <> Integer.to_string(audio_index)
          result = List.insert_at(result, -1, audio_path)
          {result, audio_index + 1}

        "subtitle" ->
          result = List.insert_at(result, -1, path <> "#subtitle:role=main")
          {result, audio_index}

        "synchro_subtitle" ->
          result = List.insert_at(result, -1, path <> "#subtitle:role=synchronized")
          {result, audio_index}

        quality ->
          video_path = path <> "#video:id=v" <> Integer.to_string(6 - quality)
          result = List.insert_at(result, -1, video_path)
          {result, audio_index}
      end

    get_formatted_source_paths(paths, audio_index, result)
  end

  defp get_source_files(jobs) do
    source_files = ExSubtilBackend.Workflow.Step.SetLanguage.get_jobs_destination_paths(jobs)

    source_files =
      ExSubtilBackend.Workflow.Step.AudioExtraction.get_jobs_destination_paths(jobs)
      |> Enum.reject(fn path -> is_file_already_in_list?(path, source_files) end)
      |> Enum.concat(source_files)

    source_files =
      ExSubtilBackend.Workflow.Step.TtmlToMp4.get_jobs_destination_paths(jobs)
      |> Enum.reject(fn path -> is_file_already_in_list?(path, source_files) end)
      |> Enum.concat(source_files)

    ExSubtilBackend.Workflow.Step.FtpDownload.get_jobs_destination_paths(jobs)
    |> Enum.reject(fn path -> is_file_already_in_list?(path, source_files) end)
    |> Enum.concat(source_files)
  end

  defp is_file_already_in_list?(file_path, paths_list) do
    Enum.any?(paths_list, fn path ->
      Path.basename(file_path) == Path.basename(path)
    end)
  end

  defp build_gpac_parameters([], result), do: result

  defp build_gpac_parameters([param | params], result) do
    key =
      Map.get(param, "id")
      |> convert_gpac_key

    value = Map.get(param, "value")

    result = Map.put(result, key, value)
    build_gpac_parameters(params, result)
  end

  defp convert_gpac_key("segment_duration"), do: :"-dash"
  defp convert_gpac_key("fragment_duration"), do: :"-frag"
  defp convert_gpac_key(_), do: nil

  defp get_quality(nil), do: nil

  defp get_quality(path) do
    cond do
      String.ends_with?(path, "-fra.mp4") ->
        "fra"

      String.ends_with?(path, "-qad.mp4") ->
        "qad"

      String.ends_with?(path, "-qaa.mp4") ->
        "qaa"

      Regex.match?(~r/.*-[0-9]*\.mp4/, path) ->
        "subtitle"

      Regex.match?(~r/.*-[0-9]*_synchronized\.mp4/, path) ->
        "synchro_subtitle"

      Regex.match?(~r/.*-standard.\.mp4/, path) ->
        String.trim_trailing(path, ".mp4")
        |> String.split("-standard")
        |> List.last()
        |> String.to_integer()

      true ->
        nil
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
