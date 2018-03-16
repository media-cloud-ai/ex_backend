defmodule ExSubtilBackend.Workflow.Step.TtmlToMp4 do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobGpacEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  def launch(workflow) do
    path = get_ttml_file(workflow.jobs, [])

    mp4_path = String.replace(path, ".ttml", ".mp4")
    requirements = Requirements.get_required_paths(path)

    job_params = %{
      name: "ttml_to_mp4",
      workflow_id: workflow.id,
      params: %{
        kind: "ttml_to_mp4",
        requirements: requirements,
        source: %{
          path: path
        },
        destination: %{
          path: mp4_path
        },
      }
    }

    {:ok, job} = Jobs.create_job(job_params)
    params = %{
      job_id: job.id,
      parameters: job.params
    }
    JobGpacEmitter.publish_json(params)
  end

  defp get_ttml_file([], result), do: result
  defp get_ttml_file([job | jobs], result) do
    result =
      case job.name do
        "download_http" ->
          job.params
          |> Map.get("destination")
          |> Map.get("path")
        _ -> result
      end

    get_ttml_file(jobs, result)
  end

end
