defmodule ExBackendWeb.WorkflowController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep
  alias ExBackend.Workflows.Workflow

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :show, :update, :delete])
  plug(:right_technician_check when action in [:index, :show, :update, :delete])

  def index(conn, params) do
    workflows = Workflows.list_workflows(params)
    render(conn, "index.json", workflows: workflows)
  end

  def create(conn, %{"workflow" => workflow_params}) do
    case Workflows.create_workflow(workflow_params) do
      {:ok, %Workflow{} = workflow} ->
        WorkflowStep.start_next_step(workflow)

        ExBackendWeb.Endpoint.broadcast!("notifications:all", "new_workflow", %{
          body: %{workflow_id: workflow.id}
        })

        conn
        |> put_status(:created)
        |> render("show.json", workflow: workflow)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ExBackendWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    workflow =
      Workflows.get_workflow!(id)
      |> ExBackend.Repo.preload(:jobs)

    render(conn, "show.json", workflow: workflow)
  end

  def get(conn, %{"identifier" => "ebu_ingest"}) do
    steps = ExBackend.Workflow.Definition.EbuIngest.get_definition("#agent_identifier", "#input_filename")

    conn
    |> json(steps)
  end

  def get(conn, _params) do
    conn
    |> json(%{})
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
