defmodule ExBackend.Workflow.Step.FtpUpload do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "upload_ftp"

  def launch(workflow, step) do
    current_date =
      Timex.now()
      |> Timex.format!("%Y_%m_%d__%H_%M_%S", :strftime)

    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    case Requirements.get_source_files(workflow.jobs, step) do
      [] ->
        Jobs.create_skipped_job(workflow, step_id, @action_name)

      paths ->
        start_upload(paths, current_date, workflow, step, step_id)
    end
  end

  defp start_upload([], _current_date, _workflow, step, _step_id), do: {:ok, "started"}

  defp start_upload([file | files], current_date, workflow, step, step_id) do
    requirements = Requirements.add_required_paths(file)
    dst_path = workflow.reference <> "/" <> current_date <> "/" <> (file |> Path.basename())

    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, []) ++
        [
          %{
            "id" => "source_path",
            "type" => "string",
            "value" => file
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

    case CommonEmitter.publish_json("job_ftp", params) do
      :ok -> start_upload(files, current_date, workflow, step, step_id)
      _ -> {:error, "unable to publish message"}
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
          |> Map.get("path")
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
