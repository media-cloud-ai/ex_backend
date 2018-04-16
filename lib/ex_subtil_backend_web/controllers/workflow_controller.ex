defmodule ExSubtilBackendWeb.WorkflowController do
  use ExSubtilBackendWeb, :controller

  import ExSubtilBackendWeb.Authorize

  alias ExSubtilBackend.Workflows
  alias ExSubtilBackend.WorkflowStep
  alias ExSubtilBackend.Workflows.Workflow

  action_fallback(ExSubtilBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug :user_check when action in [:index, :show]
  plug :id_check when action in [:update, :delete]

  def index(conn, params) do
    workflows = Workflows.list_workflows(params)
    render(conn, "index.json", workflows: workflows)
  end

  def create(conn, %{"workflow" => workflow_params}) do
    case Workflows.create_workflow(workflow_params) do
      {:ok, %Workflow{} = workflow} ->
        WorkflowStep.start_next_step(workflow)

        conn
        |> put_status(:created)
        |> render("show.json", workflow: workflow)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ExSubtilBackendWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    workflow =
      Workflows.get_workflow!(id)
      |> ExSubtilBackend.Repo.preload(:jobs)

    render(conn, "show.json", workflow: workflow)
  end

  def update(conn, %{"id" => id, "workflow" => workflow_params}) do
    workflow = Workflows.get_workflow!(id)

    with {:ok, %Workflow{} = workflow} <- Workflows.update_workflow(workflow, workflow_params) do
      render(conn, "show.json", workflow: workflow)
    end
  end

  def delete(conn, %{"id" => id}) do
    workflow = Workflows.get_workflow!(id)

    with {:ok, %Workflow{}} <- Workflows.delete_workflow(workflow) do
      send_resp(conn, :no_content, "")
    end
  end
end
