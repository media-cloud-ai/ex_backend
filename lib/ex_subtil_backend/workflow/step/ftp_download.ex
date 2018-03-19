defmodule ExSubtilBackend.Workflow.Step.FtpDownload do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobFtpEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  def launch(workflow) do
    ftp_paths = ExVideoFactory.get_ftp_paths_for_video_id(workflow.reference)

    first_file =
      ftp_paths
      |> Enum.sort
      |> List.first

    start_download_via_ftp(ftp_paths, first_file, workflow)
  end

  defp start_download_via_ftp([], _first_file, _workflow), do: {:ok, "started"}
  defp start_download_via_ftp([file | files], first_file, workflow) do
    hostname = System.get_env("AKAMAI_HOSTNAME") || Application.get_env(:ex_subtil_backend, :akamai_hostname)
    username = System.get_env("AKAMAI_USERNAME") || Application.get_env(:ex_subtil_backend, :akamai_username)
    password = System.get_env("AKAMAI_PASSWORD") || Application.get_env(:ex_subtil_backend, :akamai_password)
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_subtil_backend, :work_dir) || "/tmp/ftp_francetv"

    filename = Path.basename(file)
    dst_path = work_dir <> "/" <> workflow.reference <> "/" <> filename

    requirements =
      if file != first_file do
        work_dir <> "/" <> workflow.reference <> "/" <> Path.basename(first_file)
        |> Requirements.add_required_paths
      else
        %{}
      end

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

    start_download_via_ftp(files, first_file, workflow)
  end
end
