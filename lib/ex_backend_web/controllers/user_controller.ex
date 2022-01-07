defmodule ExBackendWeb.UserController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize
  alias ExBackend.Accounts
  alias ExBackendWeb.Auth.Token
  alias Phauxth.Log

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :show, :update, :delete])
  plug(:right_administrator_check when action in [:update, :delete, :generate_credentials])

  def index(conn, params) do
    users = Accounts.list_users(params)
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    token = Token.sign(%{"email" => email})

    with {:ok, user} <- Accounts.create_user(user_params) do
      Log.info(%Log{user: user.id, message: "user created"})

      Accounts.Message.confirm_request(email, token)

      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", %{user: user, credentials: false})
    end
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    user = (id == to_string(user.id) and user) || Accounts.get(id)
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

  def generate_credentials(%Plug.Conn{assigns: %{current_user: _user}} = conn, %{
        "id" => id
      }) do
    selected_user = Accounts.get(id)

    with {:ok, user} <- Accounts.update_credentials(selected_user) do
      render(conn, "show.json", %{user: user, credentials: true})
    end
  end

  def delete_role(%Plug.Conn{assigns: %{current_user: _user}} = conn, %{"name" => role_name}) do
    updated_users = Accounts.delete_users_role(%{role: role_name})

    json(conn, updated_users)
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
end
