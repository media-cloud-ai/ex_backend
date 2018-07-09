defmodule ExBackend.Workflow.Step.FtpUpload do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.JobFtpEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "upload_ftp"

  def launch(workflow, _step) do
    current_date =
      Timex.now()
      |> Timex.format!("%Y_%m_%d__%H_%M_%S", :strftime)

    case ExBackend.Workflow.Step.GenerateDash.get_jobs_destination_paths(workflow.jobs) do
      [] ->
        Jobs.create_skipped_job(workflow, @action_name)

      paths ->
        start_upload(paths, current_date, workflow)
    end
  end

  defp start_upload([], _current_date, _workflow), do: {:ok, "started"}

  defp start_upload([file | files], current_date, workflow) do
    hostname =
      System.get_env("AKAMAI_VIDEO_HOSTNAME") ||
        Application.get_env(:ex_backend, :akamai_video_hostname)

    username =
      System.get_env("AKAMAI_VIDEO_USERNAME") ||
        Application.get_env(:ex_backend, :akamai_video_username)

    password =
      System.get_env("AKAMAI_VIDEO_PASSWORD") ||
        Application.get_env(:ex_backend, :akamai_video_password)

    prefix =
      System.get_env("AKAMAI_VIDEO_PREFIX") ||
        Application.get_env(:ex_backend, :akamai_video_prefix)

    requirements = Requirements.add_required_paths(file)

    job_params = %{
      name: @action_name,
      workflow_id: workflow.id,
      params: %{
        requirements: requirements,
        source: %{
          path: file
        },
        destination: %{
          path:
            prefix <>
              "/" <> workflow.reference <> "/" <> current_date <> "/" <> (file |> Path.basename()),
          hostname: hostname,
          username: username,
          password: password
        }
      }
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params
    }

    JobFtpEmitter.publish_json(params)

    start_upload(files, current_date, workflow)
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
