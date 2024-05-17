defmodule ExBackendWeb.SessionController do
  use ExBackendWeb, :controller
  use OpenApiSpex.ControllerSpecs

  import ExBackendWeb.Authorize
  alias ExBackendWeb.Auth.APIAuthPlug
  alias ExBackendWeb.Auth.Token
  alias ExBackendWeb.OpenApiSchemas
  alias PowPersistentSession.Plug.Cookie

  tags ["Session"]
  security [%{"authorization" => %OpenApiSpex.SecurityScheme{type: "http", scheme: "bearer"}}]

  plug(:guest_check when action in [:create])
  plug(:user_check when action in [:renew, :delete])

  operation :create,
    summary: "Create a session",
    description: "Log in a user with credentials to get the JWT token",
    type: :object,
    request_body: {"SessionBody", "application/json", OpenApiSchemas.Sessions.SessionBody},
    responses: [
      ok: {"Session", "application/json", OpenApiSchemas.Sessions.Session},
      unauthorized: "Unauthorized - Already logged in",
      forbidden: "Forbidden"
    ]

  def create(conn, %{"session" => %{"email" => _, "password" => _} = user_params}) do
    conn
    |> Pow.Plug.authenticate_user(user_params)
    |> case do
      {:ok, conn} ->
        conn
        |> render("info.json", %{
          info: conn.private.api_access_token,
          # renewal_token: conn.private.api_renewal_token,
          user: conn.assigns.current_user
        })

      {:error, conn} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "Invalid email or password"}})
    end
  end

  def create(conn, %{"session" => %{"access_key_id" => _, "secret_access_key" => _} = user_params}) do
    case Token.verify(conn, user_params) do
      {:ok, user} ->
        {:ok, conn, token, _} = APIAuthPlug.create_token(conn, user)

        conn
        |> render("info.json", %{info: token, user: user})

      {:error, message} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: message}})
    end
  end

  def create(conn, _) do
    conn
    |> error(:unauthorized, 401)
  end

  operation :verify,
    summary: "Verify session",
    description: "Verify current user session token"

  def verify(%Plug.Conn{assigns: %{current_user: _user}} = conn, _params) do
    conn
    |> Pow.Plug.current_user()
    |> case do
      nil ->
        conn
        |> json(%{})

      user ->
        {:ok, conn, token, _} = APIAuthPlug.create_token(conn, user)

        conn
        |> render("info.json", %{
          info: token,
          user: conn.assigns.current_user
        })
    end
  end

  operation :renew,
    summary: "Renew session",
    description: "Renew current user session token"

  def renew(conn, _params) do
    config = Pow.Plug.fetch_config(conn)

    conn
    |> APIAuthPlug.renew(config)
    |> case do
      {conn, nil} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "Invalid token"}})

      {conn, _user} ->
        json(conn, %{
          data: %{
            access_token: conn.private.api_access_token,
            renewal_token: conn.private.api_renewal_token
          }
        })
    end
  end

  operation :delete,
    summary: "Delete a session",
    description: "Log out current user"

  def delete(conn, _params) do
    config = Pow.Plug.fetch_config(conn)

    conn
    |> Cookie.delete(config)
    |> Pow.Plug.Session.delete(config)
    |> Pow.Plug.delete()
    |> json(%{data: %{}})
  end
end
