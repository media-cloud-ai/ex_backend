defmodule ExSubtilBackend.Workflow.Step.FtpDownload do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobFtpEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  def launch(workflow) do
    ExVideoFactory.get_ftp_paths_for_video_id(workflow.reference)
    |> start_download_via_ftp(workflow)
  end

  defp start_download_via_ftp([], _workflow), do: {:ok, "started"}
  defp start_download_via_ftp([file | files], workflow) do
    hostname = System.get_env("AKAMAI_HOSTNAME") || Application.get_env(:ex_subtil_backend, :akamai_hostname)
    username = System.get_env("AKAMAI_USERNAME") || Application.get_env(:ex_subtil_backend, :akamai_username)
    password = System.get_env("AKAMAI_PASSWORD") || Application.get_env(:ex_subtil_backend, :akamai_password)
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_subtil_backend, :work_dir) || "/tmp/ftp_francetv"

    filename = Path.basename(file)
    dst_path = work_dir <> "/" <> workflow.reference <> "/" <> filename
    requirements = Requirements.get_required_first_dash_quality_path(dst_path)

    job_params = %{
      name: "download_ftp",
      workflow_id: workflow.id,
      params: %{
        source: %{
          path: file,
          hostname: hostname,
          username: username,
          password: password,
        },
        requirements: requirements,
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
    JobFtpEmitter.publish_json(params)

    start_download_via_ftp(files, workflow)
  end
end
