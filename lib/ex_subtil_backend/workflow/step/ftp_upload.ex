defmodule ExSubtilBackend.Workflow.Step.FtpUpload do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobFtpEmitter

  def launch(workflow, _step) do
    get_paths(workflow.jobs, [])
    |> start_upload(workflow.id)
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


  defp start_upload([], _workflow_id), do: {:ok, "started"}
  defp start_upload([file | files], workflow_id) do
    hostname = System.get_env("AKAMAI_VIDEO_HOSTNAME") || Application.get_env(:ex_subtil_backend, :akamai_video_hostname)
    username = System.get_env("AKAMAI_VIDEO_USERNAME") || Application.get_env(:ex_subtil_backend, :akamai_video_username)
    password = System.get_env("AKAMAI_VIDEO_PASSWORD") || Application.get_env(:ex_subtil_backend, :akamai_video_password)

    job_params = %{
      name: "upload_ftp",
      workflow_id: workflow_id,
      params: %{
        source: %{
          path: file
        },
        destination: %{
          path: "/421959/prod/innovation/SubTil/" <> (file |> Path.basename),
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

    start_upload(files, workflow_id)
  end

end
