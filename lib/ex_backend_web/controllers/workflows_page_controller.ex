defmodule ExBackendWeb.WorkflowsPageController do
  use ExBackendWeb, :controller
  use OpenApiSpex.ControllerSpecs

  require Logger
  import ExBackendWeb.Authorize

  alias ExBackend.Accounts
  alias ExBackendWeb.WorkflowsPageView
  alias StepFlow.Controllers.Statistics.Durations
  alias StepFlow.Workflows

  tags ["WorkflowsPage"]
  security [%{"authorization" => %OpenApiSpex.SecurityScheme{type: "http", scheme: "bearer"}}]

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index])

  operation :index,
    summary: "List workflows with aggregated details",
    description: "List workflows retrieving user details, durations, etc.",
    type: :object,
    responses: [
      ok:
        {"WorkflowsPage", "application/json",
         ExBackendWeb.OpenApiSchemas.WorkflowsPage.WorkflowsPage},
      forbidden: "Forbidden"
    ]

  def index(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    params =
      params
      |> Map.put("roles", user.roles)

    workflows_response =
      params
      |> Workflows.list_workflows()

    durations_response =
      params
      |> Durations.list_durations_for_workflows()

    if durations_response.total == workflows_response.total do
      users =
        workflows_response.data
        |> Enum.map(fn workflow -> {workflow.id, workflow.user_uuid} end)
        |> Enum.map(fn {workflow_id, user_uuid} ->
          {workflow_id, Accounts.get_by(%{"uuid" => user_uuid})}
        end)

      conn
      |> put_view(WorkflowsPageView)
      |> render("index.json",
        workflows_page: %{
          workflows: workflows_response.data,
          durations: durations_response.data,
          users: users,
          total: workflows_response.total
        }
      )
    else
      conn
      |> put_status(:internal_server_error)
      |> json("Invalid database content")
    end
  end
end
