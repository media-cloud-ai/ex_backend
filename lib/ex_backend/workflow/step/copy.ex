defmodule ExBackend.Workflow.Step.Copy do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "copy"

  def launch(workflow, step) do
    case Requirements.get_source_files(workflow.jobs, step) do
      [] ->
        Jobs.create_skipped_job(
          workflow,
          ExBackend.Map.get_by_key_or_atom(step, :id),
          @action_name
        )

      paths ->
        requirements = Requirements.add_required_paths(paths)

        parameters =
          ExBackend.Map.get_by_key_or_atom(step, :parameters)
          |> Requirements.parse_parameters(workflow)

        parameters =
          parameters ++ [
            %{
              "id" => "action",
              "type" => "string",
              "value" => @action_name
            },
            %{
              "id" => "requirements",
              "type" => "requirements",
              "value" => requirements
            },
            %{
              "id" => "source_paths",
              "type" => "paths",
              "value" => paths
            }
          ]

        job_params = %{
          name: @action_name,
          step_id: ExBackend.Map.get_by_key_or_atom(step, :id),
          workflow_id: workflow.id,
          params: %{list: parameters}
        }

        {:ok, job} = Jobs.create_job(job_params)

        params = %{
          job_id: job.id,
          parameters: job.params.list
        }

        case CommonEmitter.publish_json("job_file_system", params) do
          :ok -> {:ok, "started"}
          _ -> {:error, "unable to publish message"}
        end
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
            paths -> Enum.concat(paths, result)
          end

        _ ->
          result
      end

    get_jobs_destination_paths(jobs, result)
  end
end
