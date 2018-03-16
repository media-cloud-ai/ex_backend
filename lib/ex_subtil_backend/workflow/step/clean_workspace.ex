defmodule ExSubtilBackend.Workflow.Step.CleanWorkspace do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobCleanEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  def launch(workflow) do

    paths = get_source_files(workflow.jobs, [])

    requirements = Requirements.get_required_paths(paths)

    job_params = %{
      name: "clean_workspace",
      workflow_id: workflow.id,
      params: %{
        kind: "clean_workspace",
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
    JobCleanEmitter.publish_json(params)
  end

  defp get_source_files([], result), do: result
  defp get_source_files([job | jobs], result) do
    result =
      case job.name do
        "generate_dash" ->
          dst_dir =
            job.params
            |> Map.get("destination")
            |> Map.get("paths")
            |> List.first
            |> Path.dirname

          if dst_dir != nil do
            List.insert_at(result, -1, dst_dir)
          else
            result
          end

        "ttml_to_mp4" ->
          src_dir =
            job.params
            |> Map.get("destination")
            |> Map.get("paths")
            |> Path.dirname

          if src_dir != nil do
            List.insert_at(result, -1, src_dir)
          else
            result
          end

        _ -> result
      end

    get_source_files(jobs, result)
  end

end
