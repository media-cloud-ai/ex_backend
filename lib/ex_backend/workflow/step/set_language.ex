defmodule ExBackend.Workflow.Step.SetLanguage do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "set_language"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    case Requirements.get_source_files(workflow.jobs, step) do
      [] -> Jobs.create_skipped_job(workflow, step_id, @action_name)
      paths -> start_setting_languages(paths, workflow, step, step_id)
    end
  end

  defp start_setting_languages([], _workflow, _step, _step_id), do: {:ok, "started"}

  defp start_setting_languages([nil | paths], workflow, step, step_id) do
    start_setting_languages(paths, workflow, step, step_id)
  end

  defp start_setting_languages([path | paths], workflow, step, step_id) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    params =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, [])
      |> Enum.filter(fn param ->
        ExBackend.Map.get_by_key_or_atom(param, :id) in ["language"]
      end)
      |> Enum.map(fn param ->
        %{
          ExBackend.Map.get_by_key_or_atom(param, :id) =>
            ExBackend.Map.get_by_key_or_atom(param, :value)
        }
      end)
      |> Enum.reduce(%{}, fn param, acc -> Map.merge(acc, param) end)

    language_code =
      case params do
        %{"language" => language} -> language
        _ -> get_file_language(path, workflow)
      end

    dst_path =
      work_dir <>
        "/" <>
        Integer.to_string(workflow.id) <>
        "/lang/" <> Path.basename(path, ".mp4") <> "-" <> language_code <> ".mp4"

    requirements = Requirements.add_required_paths(path)

    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, []) ++ [
        %{
          "id" => "action",
          "type" => "string",
          "value" => @action_name
        },
        %{
          "id" => "source_path",
          "type" => "string",
          "value" => path
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
        }
      ]

    job_params = %{
      name: @action_name,
      step_id: step_id,
      workflow_id: workflow.id,
      params: %{list: parameters}
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params.list
    }

    case CommonEmitter.publish_json("job_gpac", params) do
      :ok -> start_setting_languages(paths, workflow, step, step_id)
      _ -> {:error, "unable to publish message"}
    end
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
