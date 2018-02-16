defmodule ExSubtilBackendWeb.TextController do
  use ExSubtilBackendWeb, :controller

  def index(conn, _params) do
    workflow_id = 38

    response =
      ExSubtilBackend.Workflows.get_workflow!(workflow_id)
      |> ExSubtilBackend.WorkflowStep.start_next_step

    conn
    |> json(%{status: "response"})
  end
end
