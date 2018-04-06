defmodule ExSubtilBackend.Workflow.Step.TtmlToMp4 do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobGpacEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  @action_name "ttml_to_mp4"

  def launch(workflow) do
    case get_ttml_file(workflow.jobs) do
      nil ->
        Jobs.create_skipped_job(workflow, @action_name)
      path ->
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
  end

  defp get_ttml_file(jobs) do
    Enum.find(jobs, fn(job) -> job.name == "acs_synchronize" end)
    |> case do
        nil ->
          Enum.find(jobs, fn(job) -> job.name == "download_http" end)
          |> Map.get(:params)
          |> Map.get("destination", %{})
          |> Map.get("path")
        job ->
          job.params
          |> Map.get("destination", %{})
          |> Map.get("paths")
          |> List.first
      end
  end

end
