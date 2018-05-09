defmodule ExSubtilBackendWeb.WorkflowEventsController do
  use ExSubtilBackendWeb, :controller

  import ExSubtilBackendWeb.Authorize

  alias ExSubtilBackend.Workflows

  action_fallback(ExSubtilBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:handle])
  plug(:right_technician_check when action in [:handle])

  def handle(conn, %{"id" => id, "event" => %{"abort" => abort, "skip" => step} }) do

    workflow = Workflows.get_workflow!(id)

    if abort do
      workflow.flow.steps
      |> skip_remaining_steps(workflow)

      ExSubtilBackend.Workflow.Step.CleanWorkspace.launch(workflow)
    end

    render(conn, "show.json", workflow: Workflows.get_workflow!(id))
  end

  defp skip_remaining_steps([], _workflow), do: nil
  defp skip_remaining_steps([step | steps], workflow) do
    case Map.get(step, "name") do
      "clean_workspace" ->
        nil

      _ ->
        case step.status do
          "queued" -> ExSubtilBackend.WorkflowStep.skip_step(workflow, step)
          "processing" -> ExSubtilBackend.WorkflowStep.skip_step_jobs(workflow, step)
          _ -> nil
        end
    end
    skip_remaining_steps(steps, workflow)
  end

end
