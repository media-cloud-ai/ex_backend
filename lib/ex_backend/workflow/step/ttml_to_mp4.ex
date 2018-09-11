defmodule ExBackend.Workflow.Step.TtmlToMp4 do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.JobGpacEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "ttml_to_mp4"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    ExBackend.Workflow.Step.Requirements.get_source_files(workflow.jobs, step)
    |> case do
      [] ->
        Jobs.create_skipped_job(workflow, step_id, @action_name)

      paths ->
        start_process(paths, workflow, step_id)
    end
  end

  defp start_process([], _workflow, _step_id), do: {:ok, "started"}

  defp start_process([nil | paths], workflow, step_id) do
    start_process(paths, workflow, step_id)
  end

  defp start_process([path | paths], workflow, step_id) do
    mp4_path = String.replace(path, ".ttml", ".mp4")
    requirements = Requirements.add_required_paths(path)

    job_params = %{
      name: @action_name,
      step_id: step_id,
      workflow_id: workflow.id,
      params: %{
        kind: @action_name,
        requirements: requirements,
        source: %{
          path: path
        },
        destination: %{
          path: mp4_path
        }
      }
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params
    }

    JobGpacEmitter.publish_json(params)

    start_process(paths, workflow, step_id)
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
