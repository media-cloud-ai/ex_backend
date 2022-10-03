defmodule ExBackendWeb.UserController do
  use ExBackendWeb, :controller
  use PhoenixSwagger

  require Logger

  import ExBackendWeb.Authorize
  alias ExBackend.Accounts
  alias ExBackend.Filters
  alias ExBackendWeb.Auth.Token
  alias Phauxth.Log

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :show, :update, :delete, :get_workflow_filters])

  plug(
    :right_administrator_check
    when action in [:update, :delete, :generate_credentials, :generate_validation_link]
  )

  def swagger_definitions do
    %{
      User:
        swagger_schema do
          title("User")
          description("A user of MCAI Backend")

          properties do
            access_key_id(:string, "API Access key ID")
            confirmed_at(:string, "Users confirmation date")
            email(:string, "Users email")
            first_name(:string, "Users first name")
            id(:string, "Unique identifier in database")
            inserted_at(:string, "Users insertion date")
            last_name(:string, "Users last name")
            roles(:array, "Users attached roles")
            username(:string, "Username")
            address(:string, "Home address")
            uuid(:string, "Unique identifier")

            secret_access_key(
              :string,
              "API Secret access key (only present when generating credentials)"
            )
          end

          example(%{
            access_key_id: "MCAIYTDAEPDJEMS0K02M",
            confirmed_at: "2022-09-23T21:30:15.000000Z",
            email: "editor@media-cloud.ai",
            first_name: "MCAI",
            id: 3,
            inserted_at: "2022-09-23T21:30:15",
            last_name: "Editor",
            roles: [
              "editor"
            ],
            username: "editor",
            uuid: "783e6266-f358-4afb-923c-2afd2266ded8",
            secret_access_key: "xxxxxxxxxxxxx"
          })
        end,
      Users:
        swagger_schema do
          title("Users")
          description("A collection of Users")
          type(:array)
          items(Schema.ref(:User))
        end,
      Authorized:
        swagger_schema do
          title("Authorized")
          description("Authorization response")

          properties do
            authorized(:bool, "If authorized to do action on given entity")
          end

          example(%{
            authorized: true
          })
        end,
      ValidationLink:
        swagger_schema do
          title("Validation Link")
          description("Validation Link for inscription validation")

          properties do
            authorized(:string, "Link")
          end

          example(%{
            validation_link: "http://media-cloud.ai/confirm?key=SFMyNTY.xxxxxxxxxxxxxxx"
          })
        end,
      Emails:
        swagger_schema do
          title("Accounts emails")
          description("Emails from accounts")
          type(:array)
          items(%Schema{type: :string})

          example([
            "admin@media-cloud.ai",
            "technician@media-cloud.ai"
          ])
        end
    }
  end

  swagger_path :index do
    get("/api/users")
    summary("List users")
    description("List all users registered in MCAI Backend")
    produces("application/json")
    tag("Users")
    operation_id("list_users")
    security([%{Bearer: []}])
    response(200, "OK", Schema.ref(:Users))
    response(403, "Unauthorized")
  end

  def index(conn, params) do
    users = Accounts.list_users(params)
    render(conn, "index.json", users: users)
  end

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

  swagger_path :show do
    get("/api/users/{id}")
    summary("Get user (id)")
    description("Get a user by id")
    produces("application/json")
    tag("Users")
    operation_id("get_user_by_id")

    parameters do
      id(:path, :integer, "User ID", required: true)
    end

    security([%{Bearer: []}])
    response(200, "OK", Schema.ref(:User))
    response(403, "Unauthorized")
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    user = (id == to_string(user.id) and user) || Accounts.get(id)
    render(conn, "show.json", %{user: user, credentials: false})
  end

  swagger_path :get_by_uuid do
    get("/api/users/search/{uuid}")
    summary("Get user (uuid)")
    description("Get a user by uuid")
    produces("application/json")
    tag("Users")
    operation_id("get_user_by_uuid")

    parameters do
      uuid(:path, :string, "User UUID", required: true)
    end

    security([%{Bearer: []}])
    response(200, "OK", Schema.ref(:User))
    response(403, "Unauthorized")
  end

  def get_by_uuid(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"uuid" => uuid}) do
    user = (uuid == to_string(user.uuid) and user) || Accounts.get_by(%{"uuid" => uuid})
    render(conn, "show.json", %{user: user, credentials: false})
  end

  def update(%Plug.Conn{assigns: %{current_user: _user}} = conn, %{
        "id" => id,
        "user" => user_params
      }) do
    selected_user = Accounts.get(id)

    with {:ok, user} <- Accounts.update_user(selected_user, user_params) do
      render(conn, "show.json", %{user: user, credentials: false})
    end
  end

  swagger_path :generate_credentials do
    post("/api/users/generate_credentials")
    summary("Generate credentials")
    description("Generate credentials for a user")
    produces("application/json")
    tag("Users")
    operation_id("generate_credentials")

    parameters do
      id(:query, :integer, "User ID", required: true)
    end

    security([%{Bearer: []}])
    response(200, "OK", Schema.ref(:User))
    response(403, "Unauthorized")
  end

  def generate_credentials(%Plug.Conn{assigns: %{current_user: _user}} = conn, %{
        "id" => id
      }) do
    selected_user = Accounts.get(id)

    with {:ok, user} <- Accounts.update_credentials(selected_user) do
      render(conn, "show.json", %{user: user, credentials: true})
    end
  end

  swagger_path :check_rights do
    post("/api/users/check_rights")
    summary("Check rights")
    description("Check users rights for action on entity")
    produces("application/json")
    tag("Users")
    operation_id("check_rights")

    parameters do
      entity(:query, :string, "Entity", required: true)
      action(:query, :string, "Action", required: true)
    end

    security([%{Bearer: []}])
    response(200, "OK", Schema.ref(:Authorized))
    response(403, "Unauthorized")
  end

  def check_rights(%Plug.Conn{assigns: %{current_user: user}} = conn, %{
        "entity" => entity_name,
        "action" => action
      }) do
    with {:ok, authorized} <- Accounts.check_user_rights(user, entity_name, action) do
      json(conn, %{authorized: authorized})
    end
  end

  swagger_path :generate_validation_link do
    post("/api/users/generate_validation_link")
    summary("Generate validation link")
    description("Generate validation link for user")
    produces("application/json")
    tag("Users")
    operation_id("generate_validation_link")

    parameters do
      id(:query, :integer, "User ID", required: true)
    end

    security([%{Bearer: []}])
    response(200, "OK", Schema.ref(:ValidationLink))
    response(403, "Unauthorized")
  end

  def generate_validation_link(%Plug.Conn{assigns: %{current_user: user}} = conn, %{
        "id" => id
      }) do
    user = (id == to_string(user.id) and user) || Accounts.get(id)

    token = Token.sign(%{"email" => user.email})
    validation_link = Accounts.Message.get_url_base() <> "/confirm?key=" <> token
    json(conn, %{validation_link: validation_link})
  end

  swagger_path :delete_role do
    PhoenixSwagger.Path.delete("/api/users/roles/{name}")
    summary("Delete role")
    description("Delete role by name")
    produces("application/json")
    tag("Users")
    operation_id("delete_role")

    parameters do
      name(:path, :string, "Role name", required: true)
    end

    security([%{Bearer: []}])
    response(200, "OK", Schema.ref(:Emails))
    response(403, "Unauthorized")
  end

  def delete_role(%Plug.Conn{assigns: %{current_user: _user}} = conn, %{"name" => role_name}) do
    updated_users = Accounts.delete_users_role(%{role: role_name})

    json(conn, updated_users)
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete("/api/users")
    summary("Delete user")
    description("Delete user by id")
    produces("application/json")
    tag("Users")
    operation_id("delete_user")

    parameters do
      id(:query, :integer, "User ID", required: true)
    end

    security([%{Bearer: []}])
    response(204, "No Content")
    response(403, "Unauthorized")
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    selected_user = Accounts.get(Map.get(params, "id") |> String.to_integer())

    if selected_user.id != user.id do
      {:ok, _user} = Accounts.delete_user(selected_user)
      send_resp(conn, :no_content, "")
    else
      send_resp(conn, 403, "unable to delete yourself")
    end
  end

  def get_workflow_filters(%Plug.Conn{assigns: %{current_user: user}} = conn, param) do
    filters = Filters.list_workflow_filter_for_user(%{"user_id" => user.id})
    json(conn, filters)
  end

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
