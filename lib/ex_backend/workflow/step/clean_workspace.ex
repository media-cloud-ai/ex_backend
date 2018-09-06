defmodule ExBackend.Workflow.Step.CleanWorkspace do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.JobFileSystemEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "clean_workspace"

  def launch(workflow) do
    workflow
    |> Map.get(:flow)
    |> Map.get("steps")
    |> Enum.filter(fn step ->
      Map.get(step, "name") == @action_name
    end)
    |> Enum.map(fn step ->
      launch(workflow, step)
    end)
  end

  def launch(workflow, step) do
    case get_source_directories(workflow.jobs) do
      [] ->
        Jobs.create_skipped_job(
          workflow,
          ExBackend.Map.get_by_key_or_atom(step, :id),
          @action_name
        )

      paths ->
        requirements = Requirements.add_required_paths(paths)

        job_params = %{
          name: @action_name,
          step_id: ExBackend.Map.get_by_key_or_atom(step, :id),
          workflow_id: workflow.id,
          params: %{
            action: "remove",
            requirements: requirements,
            source: %{
              paths: paths
            }
          }
        }

        {:ok, job} = Jobs.create_job(job_params)

        params = %{
          job_id: job.id,
          parameters: job.params
        }

        JobFileSystemEmitter.publish_json(params)
    end
  end

  defp get_source_directories(jobs) do
    directories =
      ExBackend.Workflow.Step.GenerateDash.get_jobs_destination_paths(jobs)
      |> get_paths_directory()

    ExBackend.Workflow.Step.FtpDownload.get_jobs_destination_paths(jobs)
    |> get_paths_directory(directories)
  end

  defp get_paths_directory(_paths, directories \\ [])
  defp get_paths_directory([], directories), do: directories

  defp get_paths_directory(paths, directories) do
    dir =
      List.first(paths)
      |> Path.dirname()

    List.insert_at(directories, -1, dir)
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
