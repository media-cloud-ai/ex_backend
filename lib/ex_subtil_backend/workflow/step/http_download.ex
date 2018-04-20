defmodule ExSubtilBackend.Workflow.Step.HttpDownload do
  alias ExSubtilBackend.Repo
  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobHttpEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  @action_name "download_http"

  def launch(workflow) do
    first_job_state =
      workflow.jobs
      |> List.first()
      |> Repo.preload(:status)
      |> Map.get(:status)
      |> List.first()
      |> Map.get(:state)

    case {first_job_state, ExVideoFactory.get_http_url_for_ttml(workflow.reference)} do
      {"skipped", _} -> Jobs.create_skipped_job(workflow, @action_name)
      {_, []} -> Jobs.create_skipped_job(workflow, @action_name)
      {_, urls} -> start_download_via_http(urls, workflow)
    end
  end

  defp start_download_via_http([], _workflow), do: {:ok, "started"}

  defp start_download_via_http([url | urls], workflow) do
    work_dir =
      System.get_env("WORK_DIR") || Application.get_env(:ex_subtil_backend, :work_dir) ||
        "/tmp/ftp_francetv"

    filename = Path.basename(url)
    dst_path = work_dir <> "/" <> workflow.reference <> "_" <> Integer.to_string(workflow.id) <> "/" <> filename

    requirements = Requirements.add_required_paths(Path.dirname(dst_path))

    job_params = %{
      name: @action_name,
      workflow_id: workflow.id,
      params: %{
        requirements: requirements,
        source: %{
          path: url
        },
        destination: %{
          path: dst_path
        }
      }
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params
    }

    JobHttpEmitter.publish_json(params)
    start_download_via_http(urls, workflow)
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
