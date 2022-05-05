defmodule ExBackendWeb.SessionController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize
  alias ExBackendWeb.Auth.Token

  plug(:guest_check when action in [:create])

  api :POST, "/api/sessions" do
    title("Create a new session")
    description(~s(Login a user with credentials to get the JWT token<br/>
    <h4>To get the token:</h4>
    <pre class=code>MIO_TOKEN=`curl -H \"Content-Type: application/json\" -d '{\"session\": {\"email\": \"user@media-io.com\", \"password\": \"secret_password\"} }' https://backend.media-io.com/api/sessions | jq -r \".access_token\"`</pre>
    ))

    parameter(:session, :map,
      optional: false,
      description: "Map with required parameters email and password"
    )
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
