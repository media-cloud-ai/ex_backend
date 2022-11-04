defmodule ExBackendWeb.UserController do
  use ExBackendWeb, :controller
  use OpenApiSpex.ControllerSpecs

  require Logger

  import ExBackendWeb.Authorize
  alias ExBackend.Accounts
  alias ExBackend.Filters
  alias ExBackendWeb.Auth.Token
  alias ExBackendWeb.OpenApiSchemas
  alias Phauxth.Log

  tags ["Users"]
  security [%{"authorization" => %OpenApiSpex.SecurityScheme{type: "http", scheme: "bearer"}}]

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :show, :update, :delete, :get_workflow_filters])

  plug(
    :right_administrator_check
    when action in [:update, :delete, :generate_credentials, :generate_validation_link]
  )

  operation :index,
    summary: "List users",
    description: "List all users registered in MCAI Backend",
    type: :object,
    responses: [
      ok: {"Users", "application/json", OpenApiSchemas.Users.Users},
      forbidden: "Forbidden"
    ]

  def index(conn, params) do
    users = Accounts.list_users(params)
    render(conn, "index.json", users: users)
  end

  operation :create, false

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    token = Token.sign(%{"email" => email})

    with {:ok, user} <- Accounts.create_user(user_params) do
      Log.info(%Log{user: user.id, message: "user created"})

      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", %{user: user, credentials: false})

      case Accounts.Message.confirm_request(email, token) do
        {:ok, _} ->
          conn
          |> put_status(:created)
          |> put_resp_header("location", user_path(conn, :show, user))
          |> render("show.json", %{user: user, credentials: false})

        {:error, error} ->
          Logger.error("Email delivery failure: #{inspect(error)}")

          conn
          |> send_resp(500, "Internal Server Error")
      end
    end
  end

  operation :show,
    summary: "Get user (id)",
    description: "Get a user by id",
    type: :object,
    parameters: [
      id: [
        in: :path,
        description: "User ID",
        type: :integer,
        example: 1
      ]
    ],
    responses: [
      ok: {"User", "application/json", OpenApiSchemas.Users.User},
      forbidden: "Forbidden",
      not_found: "Not Found"
    ]

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    user = (id == to_string(user.id) and user) || Accounts.get(id)
    render(conn, "show.json", %{user: user, credentials: false})
  end

  operation :get_by_uuid,
    summary: "Get user (uuid)",
    description: "Get a user by uuid",
    type: :object,
    parameters: [
      uuid: [
        in: :path,
        description: "User UUID",
        type: :string,
        example: "d8d50a08-3021-4fea-8a22-a9a6c4fb5055"
      ]
    ],
    responses: [
      ok: {"User", "application/json", OpenApiSchemas.Users.User},
      forbidden: "Forbidden",
      not_found: "Not Found"
    ]

  def get_by_uuid(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"uuid" => uuid}) do
    user = (uuid == to_string(user.uuid) and user) || Accounts.get_by(%{"uuid" => uuid})
    render(conn, "show.json", %{user: user, credentials: false})
  end

  operation :update, false

  def update(%Plug.Conn{assigns: %{current_user: _user}} = conn, %{
        "id" => id,
        "user" => user_params
      }) do
    selected_user = Accounts.get(id)

    with {:ok, user} <- Accounts.update_user(selected_user, user_params) do
      render(conn, "show.json", %{user: user, credentials: false})
    end
  end

  operation :generate_credentials,
    summary: "Generate credentials",
    description: "Generate credentials for a user",
    type: :object,
    request_body: {"ID Body", "application/json", OpenApiSchemas.Users.IdBody},
    responses: [
      ok: {"User", "application/json", OpenApiSchemas.Users.UserFull},
      forbidden: "Forbidden",
      not_found: "Not Found"
    ]

  def generate_credentials(%Plug.Conn{assigns: %{current_user: _user}} = conn, %{
        "id" => id
      }) do
    selected_user = Accounts.get(id)

    with {:ok, user} <- Accounts.update_credentials(selected_user) do
      render(conn, "show.json", %{user: user, credentials: true})
    end
  end

  operation :check_rights,
    summary: "Check rights",
    description: "Check user rights for action on entity",
    type: :object,
    request_body:
      {"Check Rights Body", "application/json", OpenApiSchemas.Rights.CheckRightsBody},
    responses: [
      ok: {"Authorized", "application/json", OpenApiSchemas.Rights.Authorized},
      forbidden: "Forbidden"
    ]

  def check_rights(%Plug.Conn{assigns: %{current_user: user}} = conn, %{
        "entity" => entity_name,
        "action" => action
      }) do
    with {:ok, authorized} <- Accounts.check_user_rights(user, entity_name, action) do
      json(conn, %{authorized: authorized})
    end
  end

  operation :generate_validation_link,
    summary: "Generate validation link",
    description: "Generate validation link for user",
    type: :object,
    request_body: {"ID Body", "application/json", OpenApiSchemas.Users.IdBody},
    responses: [
      ok: {"Validation Link", "application/json", OpenApiSchemas.Users.ValidationLink},
      forbidden: "Forbidden",
      not_found: "Not Found"
    ]

  def generate_validation_link(%Plug.Conn{assigns: %{current_user: user}} = conn, %{
        "id" => id
      }) do
    user = (id == to_string(user.id) and user) || Accounts.get(id)

    token = Token.sign(%{"email" => user.email})
    validation_link = Accounts.Message.get_url_base() <> "/confirm?key=" <> token
    json(conn, %{validation_link: validation_link})
  end

  operation :delete_role,
    summary: "Delete role",
    description: "Delete role by name",
    type: :object,
    parameters: [
      id: [
        in: :path,
        description: "Role name",
        type: :string,
        example: "technician"
      ]
    ],
    responses: [
      no_content: "No Content",
      forbidden: "Forbidden",
      not_found: "Not Found"
    ]

  def delete_role(%Plug.Conn{assigns: %{current_user: _user}} = conn, %{"name" => role_name}) do
    updated_users = Accounts.delete_users_role(%{role: role_name})

    json(conn, updated_users)
  end

  operation :delete,
    summary: "Delete user",
    description: "Delete user by id",
    type: :object,
    parameters: [
      id: [
        in: :path,
        description: "User ID",
        type: :integer,
        example: 1
      ]
    ],
    responses: [
      no_content: "No Content",
      forbidden: "Forbidden",
      not_found: "Not Found"
    ]

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    selected_user = Accounts.get(Map.get(params, "id") |> String.to_integer())

    if selected_user.id != user.id do
      {:ok, _user} = Accounts.delete_user(selected_user)
      send_resp(conn, :no_content, "")
    else
      send_resp(conn, 403, "unable to delete yourself")
    end
  end

  operation :get_workflow_filters,
    summary: "Get user workflow filters",
    description: "Get user workflow filters",
    type: :object,
    responses: [
      ok: {"Filters", "application/json", OpenApiSchemas.Users.Filters},
      forbidden: "Forbidden"
    ]

  def get_workflow_filters(%Plug.Conn{assigns: %{current_user: user}} = conn, _param) do
    filters = Filters.list_workflow_filter_for_user(%{"user_id" => user.id})
    json(conn, filters)
  end

  operation :save_workflow_filters,
    summary: "Save users workflows filter",
    description: "Save users workflows filter",
    type: :object,
    request_body: {"Filter Body", "application/json", OpenApiSchemas.Users.FilterBody},
    responses: [
      ok: "User workflow filters properly saved",
      forbidden: "Forbidden"
    ]

  def save_workflow_filters(%Plug.Conn{assigns: %{current_user: user}} = conn, %{
        "filter_name" => filter_name,
        "filters" => filters
      }) do
    Filters.save_user_workflow_filters(%{
      "user_id" => user.id,
      "type" => :workflow,
      "name" => filter_name,
      "filters" => filters
    })

    send_resp(conn, 200, "User workflow filters properly saved")
  end

  operation :delete_workflow_filters,
    summary: "Delete users workflows filter",
    description: "Delete users workflows filter",
    type: :object,
    parameters: [
      filter_id: [
        in: :path,
        description: "Filter ID",
        type: :integer,
        example: 1
      ]
    ],
    responses: [
      no_content: "No Content",
      forbidden: "Forbidden",
      not_found: "Not Found"
    ]

  def delete_workflow_filters(%Plug.Conn{assigns: %{current_user: user}} = conn, %{
        "filter_id" => filter_id
      }) do
    filter = Filters.get(filter_id |> String.to_integer())

    if filter.user_id == user.id do
      {:ok, _filter} = Filters.delete_user_workflow_filter(filter)
      send_resp(conn, :no_content, "")
    else
      send_resp(conn, 403, "unable to delete a filter that you don't own")
    end
  end
end
