defmodule ExSubtilBackend.Workflow.Step.CleanWorkspace do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobFileSystemEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  @action_name "clean_workspace"

  def launch(workflow) do

    case get_source_files(workflow.jobs) do
      [] ->
        Jobs.create_skipped_job(workflow, @action_name)
      paths ->
        requirements = Requirements.add_required_paths(paths)

        job_params = %{
          name: @action_name,
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

  defp get_source_files(jobs, result \\ [])
  defp get_source_files([], result), do: result
  defp get_source_files([job | jobs], result) do
    result =
      case job.name do
        "generate_dash" ->
          dst_paths =
            job.params
            |> Map.get("destination", %{})
            |> Map.get("paths")

          case dst_paths do
            nil -> result
            dst_paths ->
              dst_dir =
                dst_paths
                |> List.first
                |> Path.dirname

              if dst_dir != nil do
                List.insert_at(result, -1, dst_dir)
              else
                result
              end
          end
        "audio_extraction" ->
          src_paths =
            job.params
            |> Map.get("destination", %{})
            |> Map.get("paths")

          case src_paths do
            nil -> result
            src_paths ->
              src_dir = Path.dirname(List.first(src_paths))
              if src_dir != nil do
                List.insert_at(result, -1, src_dir)
              else
                result
              end
          end
        _ -> result
      end

    get_source_files(jobs, result)
  end

end
