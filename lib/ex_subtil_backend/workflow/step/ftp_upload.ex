defmodule ExSubtilBackend.Workflow.Step.FtpUpload do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobFtpEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  def launch(workflow, _step) do
    current_date =
      Timex.now
      |> Timex.format!("%Y_%m_%d__%H_%M_%S", :strftime)

    get_paths(workflow.jobs, [])
    |> start_upload(current_date, workflow)
  end

  defp get_paths([], result), do: result
  defp get_paths([job | jobs], result) do
    result =
      case job.name do
        "generate_dash" ->
          paths =
            job.params
            |> Map.get("destination")
            |> Map.get("paths")

          result ++ paths
        _ -> result
      end

    get_paths(jobs, result)
  end


  defp start_upload([], _current_date, _workflow), do: {:ok, "started"}
  defp start_upload([file | files], current_date, workflow) do
    hostname = System.get_env("AKAMAI_VIDEO_HOSTNAME") || Application.get_env(:ex_subtil_backend, :akamai_video_hostname)
    username = System.get_env("AKAMAI_VIDEO_USERNAME") || Application.get_env(:ex_subtil_backend, :akamai_video_username)
    password = System.get_env("AKAMAI_VIDEO_PASSWORD") || Application.get_env(:ex_subtil_backend, :akamai_video_password)
    prefix = System.get_env("AKAMAI_VIDEO_PREFIX") || Application.get_env(:ex_subtil_backend, :akamai_video_prefix) || "/421959/prod/innovation/SubTil"
    requirements = Requirements.add_required_paths(file)

    job_params = %{
      name: "upload_ftp",
      workflow_id: workflow.id,
      params: %{
        requirements: requirements,
        source: %{
          path: file
        },
        destination: %{
          path: prefix <> "/" <> workflow.reference <> "/" <> current_date <> "/" <> (file |> Path.basename),
          hostname: hostname,
          username: username,
          password: password,
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

end
