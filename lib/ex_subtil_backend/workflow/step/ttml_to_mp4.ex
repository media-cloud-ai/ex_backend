defmodule ExSubtilBackend.Workflow.Step.TtmlToMp4 do
  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobGpacEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  @action_name "ttml_to_mp4"

  def launch(workflow, step) do
    case get_ttml_files(workflow.jobs, step) do
      [] ->
        Jobs.create_skipped_job(workflow, @action_name)

      paths ->
        start_process(paths, workflow)
    end
  end

  defp start_process([], _workflow), do: {:ok, "started"}

  defp start_process([path | paths], workflow) do
    mp4_path = String.replace(path, ".ttml", ".mp4")
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

    start_process(paths, workflow)
  end

  defp get_ttml_files(jobs, step) do
    case ExSubtilBackend.Workflow.Step.Acs.Synchronize.get_jobs_destination_paths(jobs, step) do
      [] ->
        ExSubtilBackend.Workflow.Step.HttpDownload.get_jobs_destination_paths(jobs)

      paths ->
        paths
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
