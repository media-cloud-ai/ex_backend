defmodule ExBackendWeb.SessionController do
  use ExBackendWeb, :controller
  use PhoenixSwagger

  import ExBackendWeb.Authorize
  alias ExBackendWeb.Auth.Token

  plug(:guest_check when action in [:create])

  def swagger_definitions do
    %{
      Session:
        swagger_schema do
          title("Session")
          description("A MCAI Backend API Session")

          properties do
            access_token(:string, "API Access token")
            user(:User, "User infos")
          end

          example(%{
            access_token: "SFMyNTY.xxxxxxxxxxx",
            user: %{
              email: "admin@media-cloud.ai",
              first_name: "MCAI",
              id: 1,
              last_name: "Admin",
              roles: [
                "administrator",
                "editor",
                "manager",
                "technician"
              ],
              username: "Admin"
            }
          })
        end,
      Identification:
        swagger_schema do
          title("Identification")
          description("Informations for identification")

          properties do
            access_key_id(:string, "Users access key")
            secret_access_key(:string, "Users secret key")
            email(:string, "Users email")
            password(:string, "Users password")
          end
        end
    }
  end

  swagger_path :create do
    post("/api/session")
    summary("Create a session")
    description("Log in a user with credentials to get the JWT token")
    produces("application/json")
    tag("Authentication")
    operation_id("session")

    parameters do
      session(
        :query,
        :Identification,
        "Map with user infos (email/password OR access/secret keys)",
        required: true
      )
    end

    security([%{Bearer: []}])
    response(200, "OK", Schema.ref(:Session))
    response(401, "Unauthorized - Already logged in")
    response(403, "Unauthorized")
  end

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
