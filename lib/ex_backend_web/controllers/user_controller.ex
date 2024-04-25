defmodule ExBackendWeb.UserController do
  use ExBackendWeb, :controller
  use OpenApiSpex.ControllerSpecs

  require Logger

  import ExBackendWeb.Authorize
  alias Ecto.Changeset
  alias ExBackend.Accounts
  alias ExBackend.Filters
  alias ExBackendWeb.Auth.APIAuthPlug
  alias ExBackendWeb.OpenApiSchemas

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

  def create(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.create_user(user_params)
    |> case do
      {:ok, user, conn} ->
        Logger.info("user #{user.id} created")

        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json", %{user: user, credentials: false})

      {:error, changeset, conn} ->
        errors =
          Changeset.traverse_errors(changeset, &format_creation_error/1)

        conn
        |> put_status(422)
        |> json(%{error: %{message: "Couldn't create user", errors: errors}})
    end
  end

  defp format_creation_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
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

    conn
    |> put_resp_header("cache-control", "max-age=3600")
    |> render("show.json", %{user: user, credentials: false})
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
    request_body: {"IDBody", "application/json", OpenApiSchemas.Users.IdBody},
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
    description: "Check user rights for actions on entity",
    type: :object,
    request_body: {"CheckRightsBody", "application/json", OpenApiSchemas.Rights.CheckRightsBody},
    responses: [
      ok: {"Authorized", "application/json", OpenApiSchemas.Rights.Authorized},
      forbidden: "Forbidden"
    ]

  def check_rights(%Plug.Conn{assigns: %{current_user: user}} = conn, %{
        "entity" => entity_name,
        "actions" => actions
      }) do
    with {:ok, authorizations} <- Accounts.check_user_rights(user, entity_name, actions) do
      json(conn, %{authorized: authorizations})
    end
  end

  operation :generate_validation_link,
    summary: "Generate validation link",
    description: "Generate validation link for user",
    type: :object,
    request_body: {"IDBody", "application/json", OpenApiSchemas.Users.IdBody},
    responses: [
      ok: {"ValidationLink", "application/json", OpenApiSchemas.Users.ValidationLink},
      forbidden: "Forbidden",
      not_found: "Not Found"
    ]

  def generate_validation_link(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    user = (id == to_string(user.id) and user) || Accounts.get(id)

    case APIAuthPlug.create_token(conn, user) do
      {:ok, conn, token, _} ->
        validation_link =
          Accounts.Message.get_url_base() <> "/confirm?key=" <> token

        json(conn, %{validation_link: validation_link})

      _ ->
        error(conn, 500, "Could not generate token")
    end
  end

  operation :change_password,
    summary: "Change account password",
    description: "Change account password when one has enough rights",
    type: :object,
    request_body: {"PasswordBody", "application/json", OpenApiSchemas.Users.PasswordBody},
    responses: [
      ok: {"User", "application/json", OpenApiSchemas.Users.UserFull},
      forbidden: "Forbidden",
      not_found: "Not Found"
    ]

  def change_password(%Plug.Conn{assigns: %{current_user: user}} = conn, %{
        "id" => id,
        "password" => password
      }) do
    selected_user = Accounts.get(id)

    if user.id == 1 do
      {:ok, _user} = Accounts.update_password(selected_user, %{password: password})

      conn
      |> put_status(:ok)
      |> put_view(ExBackendWeb.UserView)
      |> render("info.json", %{info: "User password successfully changed"})
    else
      send_resp(conn, 403, "Unauthorized to change User password")
    end
  end

  operation :delete_role,
    summary: "Delete role",
    description: "Delete role by name",
    type: :object,
    parameters: [
      name: [
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
    request_body: {"FilterBody", "application/json", OpenApiSchemas.Users.FilterBody},
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

    conn
    |> put_status(:created)
    |> put_view(ExBackendWeb.UserView)
    |> render("info.json", %{info: "User workflow filters properly saved"})
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
