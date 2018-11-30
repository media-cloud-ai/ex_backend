defmodule ExBackend.Workflow.Step.FtpDownload do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.JobFtpEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "download_ftp"

  def launch(workflow, step) do
    ftp_paths = ExVideoFactory.get_ftp_paths_for_video_id(workflow.reference)

    first_file =
      ftp_paths
      |> Enum.sort()
      |> List.first()

    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    case ftp_paths do
      [] -> Jobs.create_skipped_job(workflow, step_id, @action_name)
      _ -> start_download_via_ftp(ftp_paths, step, step_id, first_file, workflow)
    end
  end

  defp start_download_via_ftp([], _step, _step_id, _first_file, _workflow), do: {:ok, "started"}

  defp start_download_via_ftp([file | files], step, step_id, first_file, workflow) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    filename = Path.basename(file)

    dst_path = work_dir <> "/" <> Integer.to_string(workflow.id) <> "/" <> filename

    requirements =
      if file != first_file do
        (Path.dirname(dst_path) <> "/" <> Path.basename(first_file))
        |> Requirements.add_required_paths()
      else
        %{}
      end

    parameters =
      Map.get(step, "parameters", []) ++ [
        %{
          "id" => "source_path",
          "type" => "string",
          "value" => file
        },
        %{
          "id" => "destination_path",
          "type" => "string",
          "value" => dst_path
        },
        %{
          "id" => "requirements",
          "type" => "requirements",
          "value" => requirements
        }
      ]

    job_params = %{
      name: @action_name,
      step_id: step_id,
      workflow_id: workflow.id,
      params: %{ list: parameters }
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params.list
    }

    JobFtpEmitter.publish_json(params)

    start_download_via_ftp(files, step, step_id, first_file, workflow)
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
