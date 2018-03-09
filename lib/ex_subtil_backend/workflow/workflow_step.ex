defmodule ExSubtilBackend.WorkflowStep do
  @moduledoc """
  The Workflow Step context.
  """

  require Logger

  alias ExSubtilBackend.Workflows.Workflow

  def start_next_step(%Workflow{id: workflow_id} = workflow) do

    workflow = ExSubtilBackend.Repo.preload(workflow, :jobs)

    step_index =
      Enum.map(workflow.jobs, fn(job) -> job.name end)
      |> Enum.uniq
      |> length

    Logger.warn "#{__MODULE__}: start to process step #{step_index} for workflow #{workflow_id}"

    steps =
      workflow.flow
      |> Map.get("steps")

    step = Enum.at(steps, step_index)

    launch_step(workflow, step, step_index)
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

  defp launch_step(workflow, step, _step_index) do
    Logger.error "unable to match with the step #{inspect step} for workflow #{workflow.id}"
    {:error, "unable to match with the step #{inspect step}"}
  end
end
