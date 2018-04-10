defmodule ExSubtilBackend.Workflow.Step.Acs.Synchronize do

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobCommandLineEmitter
  alias ExSubtilBackend.Workflow.Step.Requirements

  require Logger

  @action_name "acs_synchronize"

  def launch(workflow) do
    source_files = get_source_files(workflow.jobs)
    case map_size(source_files) do
      0 -> Jobs.create_skipped_job(workflow, @action_name)
      _ -> start_processing_synchro(source_files, workflow)
    end
  end

  defp start_processing_synchro(%{ "audio_path" => audio_path, "subtitle_path" => subtitle_path }, workflow) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_subtil_backend, :work_dir) || "/tmp/ftp_francetv"

    filename = Path.basename(subtitle_path)
    dst_path = work_dir <> "/" <> workflow.reference <> "/acs/"  <> filename

    requirements = Requirements.add_required_paths([audio_path, subtitle_path])

    # TODO: execute ACS command instead of a simple copy...
    job_params = %{
      name: @action_name,
      workflow_id: workflow.id,
      params: %{
        requirements: requirements,
        program: "/bin/cp",
        inputs: [
          %{
            path: subtitle_path,
            options: %{}
          }
        ],
        outputs: [
          %{
            path: dst_path,
            options: %{}
          }
        ]
      }
    }

    {:ok, job} = Jobs.create_job(job_params)
    params = %{
      job_id: job.id,
      parameters: job.params
    }
    JobCommandLineEmitter.publish_json(params)
  end

  defp get_source_files(jobs, result \\ %{})
  defp get_source_files([], result), do: result
  defp get_source_files([job | jobs], result) do
    result =
      case job.name do
        "acs_prepare_audio" ->
          audio_path =
            job.params
            |> Map.get("destination", %{})
            |> Map.get("paths")
            |> List.first
          Map.put(result, "audio_path", audio_path)

        "download_http" ->
          subtitle_path =
            job.params
            |> Map.get("destination", %{})
            |> Map.get("path")
          Map.put(result, "subtitle_path", subtitle_path)

        _ -> result
      end

    get_source_files(jobs, result)
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
          |> Map.get("paths")
          |> Enum.concat(result)
        _ -> result
      end

    get_jobs_destination_paths(jobs, result)
  end

end
