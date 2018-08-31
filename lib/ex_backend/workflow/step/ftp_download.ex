defmodule ExBackend.Workflow.Step.FtpDownload do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.JobFtpEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "download_ftp"

  def launch(workflow) do
    ftp_paths = ExVideoFactory.get_ftp_paths_for_video_id(workflow.reference)

    first_file =
      ftp_paths
      |> Enum.sort()
      |> List.first()

    case ftp_paths do
      [] -> Jobs.create_skipped_job(workflow, @action_name)
      _ -> start_download_via_ftp(ftp_paths, first_file, workflow)
    end
  end

  defp start_download_via_ftp([], _first_file, _workflow), do: {:ok, "started"}

  defp start_download_via_ftp([file | files], first_file, workflow) do
    hostname =
      System.get_env("AKAMAI_HOSTNAME") || Application.get_env(:ex_backend, :akamai_hostname)

    username =
      System.get_env("AKAMAI_USERNAME") || Application.get_env(:ex_backend, :akamai_username)

    password =
      System.get_env("AKAMAI_PASSWORD") || Application.get_env(:ex_backend, :akamai_password)

    work_dir =
      System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    filename = Path.basename(file)

    dst_path =
      work_dir <>
        "/" <> workflow.reference <> "_" <> Integer.to_string(workflow.id) <> "/" <> filename

    requirements =
      if file != first_file do
        (Path.dirname(dst_path) <> "/" <> Path.basename(first_file))
        |> Requirements.add_required_paths()
      else
        %{}
      end

    job_params = %{
      name: @action_name,
      workflow_id: workflow.id,
      params: %{
        source: %{
          path: file,
          hostname: hostname,
          username: username,
          password: password
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
