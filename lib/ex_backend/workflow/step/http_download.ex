defmodule ExBackend.Workflow.Step.HttpDownload do
  alias ExBackend.Repo
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "download_http"

  def launch(workflow, step) do
    inputs =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, [])
      |> Enum.filter(fn param ->
        ExBackend.Map.get_by_key_or_atom(param, :id) == "source_paths"
      end)
      |> Enum.map(fn param ->
        ExBackend.Map.get_by_key_or_atom(param, :value)
      end)

    source_urls =
      case inputs do
        [] -> ExVideoFactory.get_http_url_for_ttml(workflow.reference)
        [paths] -> paths
        _ -> raise("unable to create FTP download job: missing input paths")
      end

    first_job_state =
      workflow.jobs
      |> List.first()
      |> Repo.preload(:status)
      |> Map.get(:status)
      |> List.first()
      |> Map.get(:state)

    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    case {first_job_state, source_urls} do
      {"skipped", _} -> Jobs.create_skipped_job(workflow, step_id, @action_name)
      {_, []} -> Jobs.create_skipped_job(workflow, step_id, @action_name)
      {_, urls} -> start_download(urls, step_id, step, workflow)
    end
  end

  defp start_download([], _step_id, _step, _workflow), do: {:ok, "started"}
  defp start_download([url | urls], step_id, step, workflow) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    filename = Path.basename(url)

    dst_path = work_dir <> "/" <> Integer.to_string(workflow.id) <> "/" <> filename

    requirements = Requirements.add_required_paths(Path.dirname(dst_path))

    parameters =
      Map.get(step, "parameters", []) ++ [
        %{
          "id" => "source_path",
          "type" => "string",
          "value" => url
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
      params:  %{ list: parameters }
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params.list
    }

    case CommonEmitter.publish_json("job_http", params) do
      :ok -> start_download(urls, step_id, step, workflow)
      _ -> {:error, "unable to publish message"}
    end
  end
end
