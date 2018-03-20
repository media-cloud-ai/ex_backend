defmodule ExSubtilBackend.WorkflowStep do
  @moduledoc """
  The Workflow Step context.
  """

  require Logger

  alias ExSubtilBackend.Workflows.Workflow
  alias ExSubtilBackend.Artifacts

  def start_next_step(%Workflow{id: workflow_id} = workflow) do

    workflow = ExSubtilBackend.Repo.preload(workflow, :jobs, force: true)

    step_index =
      Enum.map(workflow.jobs, fn(job) -> job.name end)
      |> Enum.uniq
      |> length

    steps =
      workflow.flow
      |> Map.get("steps")

    case Enum.at(steps, step_index) do
      nil ->
        set_artifacts(workflow)
        Logger.warn "#{__MODULE__}: workflow #{workflow_id} is completed"
      step ->
        Logger.warn "#{__MODULE__}: start to process step #{step["id"]} (index #{step_index}) for workflow #{workflow_id}"

        status = launch_step(workflow, step, step_index)
        case status do
          {:ok, "skipped"} -> start_next_step(workflow)
          _ -> status
        end
    end
  end

  defp launch_step(workflow, %{"id"=> "download_ftp"} = _step, _step_index) do
    ExSubtilBackend.Workflow.Step.FtpDownload.launch(workflow)
  end

  defp launch_step(workflow, %{"id"=> "download_http"} = _step, _step_index) do
    ExSubtilBackend.Workflow.Step.HttpDownload.launch(workflow)
  end

  defp launch_step(workflow, %{"id"=> "ttml_to_mp4"} = _step, _step_index) do
    ExSubtilBackend.Workflow.Step.TtmlToMp4.launch(workflow)
  end

  defp launch_step(workflow, %{"id"=> "set_language"} = step, _step_index) do
    ExSubtilBackend.Workflow.Step.SetLanguage.launch(workflow, step)
  end

  defp launch_step(workflow, %{"id"=> "generate_dash"} = step, _step_index) do
    ExSubtilBackend.Workflow.Step.GenerateDash.launch(workflow, step)
  end

  defp launch_step(workflow, %{"id"=> "upload_ftp"} = step, _step_index) do
    ExSubtilBackend.Workflow.Step.FtpUpload.launch(workflow, step)
  end

  defp launch_step(workflow, %{"id"=> "clean_workspace"} = _step, _step_index) do
    ExSubtilBackend.Workflow.Step.CleanWorkspace.launch(workflow)
  end

  defp launch_step(workflow, step, _step_index) do
    Logger.error "unable to match with the step #{inspect step} for workflow #{workflow.id}"
    {:error, "unable to match with the step #{inspect step}"}
  end

  defp set_artifacts(workflow) do
    paths =
      ExSubtilBackend.Workflow.Step.FtpUpload.get_paths(workflow.jobs)
      |> Enum.filter(fn(path) -> String.ends_with?(path, ".mpd") end)

    case paths do
      [] -> nil
      paths ->
        manifest = List.first(paths)
        params = %{
          resources: %{
            manifest: manifest
          },
          workflow_id: workflow.id
        }

        Artifacts.create_artifact(params)
    end
  end
end
