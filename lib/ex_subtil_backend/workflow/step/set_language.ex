defmodule ExSubtilBackend.Workflow.Step.SetLanguage do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobGpacEmitter
  alias ExSubtilBackend.Workflow.Step.GenerateDash

  def launch(workflow, step) do
    audio_source_files = get_source_files(workflow.jobs, "download_ftp", [])
    text_source_files = get_source_files(workflow.jobs, "ttml_to_mp4", [])

    Map.get(step, "parameters", [])
    |> Enum.each(fn(param) ->
      case param["id"] do
        "audio_track" -> start_setting_language(audio_source_files, workflow, param)
        "text_track" -> start_setting_language(text_source_files, workflow, param)
        other -> raise ArgumentError.exception("unknown language parameter id: " <> other)
      end
    end)
  end

  defp start_setting_language([], _workflow, _param), do: {:ok, "started"}
  defp start_setting_language([path | paths], workflow, param) do
    options = %{
      "-lang": get_language_parameters(param)
    }

    job_params = %{
      name: "set_language",
      workflow_id: workflow.id,
      params: %{
        kind: "set_language",
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

    start_setting_language(paths, workflow, param)
  end

  defp get_language_parameters(%{"id" => "audio_track"} = param) do
    Integer.to_string(param["index"] + 1) <> "=" <> param["value"]
  end
  defp get_language_parameters(%{"id" => "text_track"} = param) do
    Integer.to_string(param["index"]) <> "=" <> param["value"]
  end
  defp get_language_parameters(_) do
    raise ArgumentError.exception("unknown language parameter")
  end


  defp get_source_files([], job_name, result), do: result
  defp get_source_files([job | jobs], job_name, result) do
    result =
      if job.name == job_name do
        get_path_from_job(job_name, job.params, result)
      else
        result
      end
    get_source_files(jobs, job_name, result)
  end

  defp get_path_from_job(job_name = "download_ftp", job_params, result) do
    video_path =
      job_params
      |> Map.get("destination")
      |> Map.get("path")

    if GenerateDash.get_quality(video_path) == 1 do
      List.insert_at(result, -1, video_path)
    else
      result
    end
  end
  defp get_path_from_job(job_name = "ttml_to_mp4", job_params, result) do
    caption_path =
      job_params
      |> Map.get("destination")
      |> Map.get("paths")

    if caption_path != nil do
      List.insert_at(result, -1, caption_path)
    else
      result
    end
  end
  defp get_path_from_job(_job_name, _job_params, result), do: result

end
