defmodule ExSubtilBackend.Workflow.Step.FtpDownload do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobFtpEmitter

  def launch(workflow) do
    ExVideoFactory.get_ftp_paths_for_video_id(workflow.reference)
    |> start_download_via_ftp(workflow.id)
  end

  defp start_download_via_ftp([], _workflow_id), do: {:ok, "started"}
  defp start_download_via_ftp([file | files], workflow_id) do
    hostname = System.get_env("AKAMAI_HOSTNAME") || Application.get_env(:ex_subtil_backend, :akamai_hostname)
    username = System.get_env("AKAMAI_USERNAME") || Application.get_env(:ex_subtil_backend, :akamai_username)
    password = System.get_env("AKAMAI_PASSWORD") || Application.get_env(:ex_subtil_backend, :akamai_password)

    job_params = %{
      name: "download_ftp",
      workflow_id: workflow_id,
      params: %{
        source: %{
          path: file,
          hostname: hostname,
          username: username,
          password: password,
        },
        destination: %{
          path: "/tmp/ftp_ftv" <> file
        }
      }
    }

    {:ok, job} = Jobs.create_job(job_params)
    params = %{
      job_id: job.id,
      parameters: job.params
    }
    JobFtpEmitter.publish_json(params)

    start_download_via_ftp(files, workflow_id)
  end
end
