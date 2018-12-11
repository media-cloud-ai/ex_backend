defmodule ExBackend.Workflow.Step.GenerateDash do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  require Logger

  @action_name "generate_dash"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    case build_step_parameters(workflow, step, step_id) do
      {:skipped, nil} ->
        Jobs.create_skipped_job(workflow, step_id, @action_name)

      {:ok, job_params} ->
        {:ok, job} = Jobs.create_job(job_params)

        params = %{
          job_id: job.id,
          parameters: job.params.list
        }

        case CommonEmitter.publish_json("job_gpac", params) do
          :ok -> {:ok, "started"}
          _ -> {:error, "unable to publish message"}
        end

      something_else ->
        Logger.error(
          "#{__MODULE__}: unable to match result of build_step_parameters to #{
            inspect(something_else)
          }"
        )

        {:error, something_else}
    end
  end

  def build_step_parameters(workflow, step, step_id) do
    source_file_paths =
      ExBackend.Workflow.Step.Requirements.get_source_files(workflow.jobs, step)
      |> Enum.sort()

    formatted_source_paths = get_formatted_source_paths(source_file_paths)

    case formatted_source_paths do
      [] ->
        {:skipped, nil}

      source_track_paths ->
        source_paths =
          source_track_paths
          |> Enum.map(fn path -> String.replace(path, ~r/\.mp4#.*/, ".mp4") end)

        work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

        dst_path = work_dir <> "/" <> Integer.to_string(workflow.id) <> "/dash/manifest.mpd"

        requirements = Requirements.add_required_paths(source_paths)

        parameters =
          ExBackend.Map.get_by_key_or_atom(step, :parameters, []) ++
            [
              %{
                "id" => "action",
                "type" => "string",
                "value" => @action_name
              },
              %{
                "id" => "source_paths",
                "type" => "paths",
                "value" => source_track_paths
              },
              %{
                "id" => "destination_path",
                "type" => "string",
                "value" => dst_path
              },
              %{
                "id" => "requirements",
                "type" => "requirements",
                "value" => requirements
              },
              %{
                "id" => "profile",
                "type" => "string",
                "value" => "onDemand"
              },
              %{
                "id" => "rap",
                "type" => "boolean",
                "value" => true
              },
              %{
                "id" => "url_template",
                "type" => "boolean",
                "value" => true
              }
            ]

        {
          :ok,
          %{
            name: @action_name,
            step_id: step_id,
            workflow_id: workflow.id,
            params: %{list: parameters}
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

        "eng" ->
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

  defp build_gpac_parameters([], result), do: result

  defp get_quality(nil), do: nil

  defp get_quality(path) do
    cond do
      String.ends_with?(path, "-fra.mp4") ->
        "fra"

      String.ends_with?(path, "-eng.mp4") ->
        "eng"

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
end
