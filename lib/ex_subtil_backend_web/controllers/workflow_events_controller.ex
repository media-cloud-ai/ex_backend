defmodule ExSubtilBackendWeb.WorkflowEventsController do
  use ExSubtilBackendWeb, :controller

  import ExSubtilBackendWeb.Authorize

  alias ExSubtilBackend.Workflows

  action_fallback(ExSubtilBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:handle])
  plug(:right_technician_check when action in [:handle])

  def handle(conn, %{"workflow_id" => id, "event" => event}) do
    workflow = Workflows.get_workflow!(id)

    case event do
      "abort" ->
        workflow.flow.steps
        |> skip_remaining_steps(workflow)

        ExSubtilBackend.Workflow.Step.CleanWorkspace.launch(workflow)

        topic = "update_workflow_" <> Integer.to_string(workflow.id)
        ExSubtilBackendWeb.Endpoint.broadcast! "notifications:all", topic, %{body: %{workflow_id: workflow.id}}

        send_resp(conn, :ok, "")
      _ ->
        send_resp(conn, 422, "event is not supported")
    end
  end

  defp skip_remaining_steps([], _workflow), do: nil

  defp skip_remaining_steps([step | steps], workflow) do
    case Map.get(step, "name") do
      "clean_workspace" -> nil
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
