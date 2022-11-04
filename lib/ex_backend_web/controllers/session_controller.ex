defmodule ExBackendWeb.SessionController do
  use ExBackendWeb, :controller
  use OpenApiSpex.ControllerSpecs

  import ExBackendWeb.Authorize
  alias ExBackendWeb.Auth.Token
  alias ExBackendWeb.OpenApiSchemas

  tags ["Session"]
  security [%{"authorization" => %OpenApiSpex.SecurityScheme{type: "http", scheme: "bearer"}}]

  plug(:guest_check when action in [:create])

  operation :create,
    summary: "Create a session",
    description: "Log in a user with credentials to get the JWT token",
    type: :object,
    request_body: {"Session Body", "application/json", OpenApiSchemas.Sessions.SessionBody},
    responses: [
      ok: {"Session", "application/json", OpenApiSchemas.Sessions.Session},
      unauthorized: "Unauthorized - Already logged in",
      forbidden: "Forbidden"
    ]

  def create(conn, %{"session" => params}) do
    case Token.verify(params) do
      {:ok, user} ->
        token = Token.sign(%{"email" => user.email})
        cookie = "token=" <> token <> "; Path=/"

        conn
        |> put_resp_header("set-cookie", cookie)
        |> render("info.json", %{info: token, user: user})

      {:error, _message} ->
        error(conn, :unauthorized, 401)
    end
  end

  def create(conn, _) do
    error(conn, :unauthorized, 401)
  end
end
