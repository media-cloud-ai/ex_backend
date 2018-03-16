defmodule ExSubtilBackend.Workflow.Step.GenerateDash do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobGpacEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  def launch(workflow, step) do

    filenames_with_language = get_filenames_with_language(workflow.jobs, %{})
    source_track_paths = get_source_files(workflow.jobs, filenames_with_language, [])

    source_paths =
      source_track_paths
      |> Enum.map(fn(path) -> String.replace(path, ~r/\.mp4#.*/, ".mp4") end)

    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_subtil_backend, :work_dir) || "/tmp/ftp_francetv"

    options = %{
      "-out": work_dir <> "/dash/" <> workflow.reference <> "/manifest.mpd",
      "-profile": "onDemand",
      "-rap": true,
      "-url-template": true,
    }

    options =
      Map.get(step, "parameters", [])
      |> build_gpac_parameters(options)

    requirements = Requirements.get_path_exists(source_paths)

    job_params = %{
      name: "generate_dash",
      workflow_id: workflow.id,
      params: %{
        kind: "generate_dash",
        requirements: requirements,
        source: %{
          paths: source_track_paths
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
  end

  defp get_source_files([], _paths_with_languages, result), do: result
  defp get_source_files([job | jobs], paths_with_languages, result) do
    result =
      case job.name do
        "download_ftp" ->
          path =
            job.params
            |> Map.get("destination")
            |> Map.get("path")
            |> get_path_with_language(paths_with_languages)

          case get_quality(path) do
            1 ->
              audio_path = path <> "#trackID=2#audio:id=a1"
              video_path = path <> "#trackID=1#video:id=v" <> Integer.to_string(5)

              List.insert_at(result, -1, audio_path)
              |> List.insert_at(-1, video_path)
            "qad" ->
              audio_path = path <> "#audio:id=a2"
              List.insert_at(result, -1, audio_path)
            quality ->
              video_path = path <> "#video:id=v" <> Integer.to_string(6 - quality)
              List.insert_at(result, -1, video_path)
          end

        "ttml_to_mp4" ->
          caption_path =
            job.params
            |> Map.get("destination")
            |> Map.get("paths")
            |> get_path_with_language(paths_with_languages)

          if caption_path != nil do
            List.insert_at(result, -1, caption_path <> "#subtitle")
          else
            result
          end
          
        _ -> result
      end

    get_source_files(jobs, paths_with_languages, result)
  end

  defp get_filenames_with_language([], result), do: result
  defp get_filenames_with_language([job | jobs], result) do
    result =
      case job.name do
        "set_language" ->
          path =
            job.params
            |> Map.get("destination")
            |> Map.get("paths")
          Map.put(result, Path.basename(path), path)

        _ -> result
      end

    get_filenames_with_language(jobs, result)
  end

  defp get_path_with_language(path, paths_with_languages) do
    case Map.get(paths_with_languages, Path.basename(path)) do
      nil -> path
      new_path -> new_path
    end
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

  defp convert_gpac_key("segment_duration"), do: "-dash"
  defp convert_gpac_key("fragment_duration"), do: "-frag"
  defp convert_gpac_key(_), do: nil

  def get_quality(path) do
    if String.ends_with?(path, "-qad.mp4") do
      "qad"
    else
      String.trim_trailing(path, ".mp4")
      |> String.split("-standard")
      |> List.last
      |> String.to_integer
    end
  end
end
