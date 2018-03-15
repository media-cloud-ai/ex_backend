defmodule ExSubtilBackend.Workflow.Step.SetLanguage do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobGpacEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  def launch(workflow, _step) do
    # Get file paths
    paths = get_source_files(workflow.jobs)

    # Get track languages
    languages =
      ExVideoFactory.videos(%{"qid" => workflow.reference})
      |> Map.fetch!(:videos)
      |> List.first
      |> get_source_languages

    # Set languages
    set_text_languages(paths.text_tracks, languages.text_tracks)
    |> set_audio_languages(paths.audio_description_tracks, languages.audio_description_tracks)
    |> set_audio_languages(paths.audio_tracks, languages.audio_tracks)
    |> start_setting_languages(workflow)
  end

  defp set_audio_languages(result, [], _languages), do: result
  defp set_audio_languages(result, [path | paths], languages) do

    result = map_path_with_language(path, List.first(languages), result)

    set_audio_languages(result, paths, languages)
  end

  defp map_path_with_language(path, lang, result) do
    mapping = %{
        path: path,
        language: lang
      }
    List.insert_at(result, -1, mapping)
  end

  defp set_text_languages(result \\ [], _paths, _languages)
  defp set_text_languages(result, [], []), do: result
  defp set_text_languages(result, [path | paths], [lang | languages]) do

    result = map_path_with_language(path, lang, result)

    set_text_languages(result, paths, languages)
  end

  # defp get_track_index(mapping, acc \\ 1), do: acc
  # defp get_track_index(mapping, acc) when is_list(mapping.paths) do
  #   acc = acc + 1
  # end

  defp start_setting_languages([], _workflow), do: {:ok, "started"}
  defp start_setting_languages([mapping | languages_mapping], workflow) do

    options = %{
      "-lang": mapping.language["code"],
      "-out": Path.dirname(mapping.path)
              |> Path.join("lang")
              |> Path.join(Path.basename(mapping.path))
    }

    job_params = %{
      name: "set_language",
      workflow_id: workflow.id,
      params: %{
        kind: "set_language",
        requirement: Requirements.get_path_exists(mapping.path),
        source: %{
          path: mapping.path
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

    start_setting_languages(languages_mapping, workflow)
  end

  defp get_source_languages(video) do
    audio_tracks = Map.get(video, "audio_tracks")

    audio_description_language =
      audio_tracks
      |> Enum.find(fn(track) -> track["code"] == "QAD" end)

    %{
      audio_tracks: List.delete(audio_tracks, audio_description_language),
      audio_description_tracks: [audio_description_language],
      text_tracks: Map.get(video, "text_tracks")
    }
  end

  defp get_source_files(_jobs, result \\ %{audio_tracks: [], audio_description_tracks: [], text_tracks: []})
  defp get_source_files([], result), do: result
  defp get_source_files([job | jobs], result) do
    result =
      case job.name do
        "download_ftp" ->
          path =
            job.params
            |> Map.get("destination")
            |> Map.get("path")

          cond do
            String.ends_with?(path, "-standard1.mp4") ->
              audio_tracks =
                Map.get(result, :audio_tracks, [])
                |> List.insert_at(-1, path)
              Map.put(result, :audio_tracks, audio_tracks)

            String.ends_with?(path, "-qad.mp4") ->
              audio_description_tracks =
                Map.get(result, :audio_description_tracks, [])
                |> List.insert_at(-1, path)
              Map.put(result, :audio_description_tracks, audio_description_tracks)

            true -> result
          end

        "ttml_to_mp4" ->
          caption_path =
            job.params
            |> Map.get("destination")
            |> Map.get("paths")

          text_tracks = Map.get(result, :text_tracks, [])
          text_tracks =
            if caption_path != nil do
              List.insert_at(text_tracks, -1, caption_path)
            else
              text_tracks
            end
          Map.put(result, :text_tracks, text_tracks)

        _ -> result
      end

    get_source_files(jobs, result)
  end

end
