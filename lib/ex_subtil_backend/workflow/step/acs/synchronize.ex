defmodule ExSubtilBackend.Workflow.Step.Acs.Synchronize do

  alias ExSubtilBackend.Jobs
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
    _dst_path = work_dir <> "/" <> workflow.reference <> "/acs/"  <> filename
    |> IO.inspect

    _requirements = Requirements.add_required_paths([audio_path, subtitle_path])
    |> IO.inspect

    # TODO: publish synchronization message to ACS worker
    Jobs.create_skipped_job(workflow, @action_name)

    # {:ok, "started"}
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

end
