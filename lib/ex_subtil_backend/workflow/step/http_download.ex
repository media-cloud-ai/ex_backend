defmodule ExSubtilBackend.Workflow.Step.HttpDownload do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobHttpEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  def launch(workflow) do
    urls = ExVideoFactory.get_http_url_for_ttml(workflow.reference)

    first_url =
      urls
      |> Enum.sort
      |> List.first

    start_download_via_http(urls, first_url, workflow)
  end


  defp start_download_via_http([], _first_url, _workflow), do: {:ok, "started"}
  defp start_download_via_http([url | urls], first_url, workflow) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_subtil_backend, :work_dir) || "/tmp/ftp_francetv"
    filename = Path.basename(url)
    dst_path = work_dir <> "/" <> workflow.reference <> "/" <> filename

    requirements =
      if url == first_url do
        work_dir <> "/" <> workflow.reference <> "/" <> Path.basename(first_url)
        |> Requirements.add_required_paths
      else
        %{}
      end

    job_params = %{
      name: "download_http",
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
    start_download_via_http(urls, first_url, workflow)
  end
end
