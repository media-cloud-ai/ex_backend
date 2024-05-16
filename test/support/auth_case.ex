defmodule ExBackendWeb.AuthCase do
  @moduledoc false

  import Ecto.Changeset
  import Plug.Conn

  alias ExBackendWeb.Auth.APIAuthPlug
  alias ExBackend.{Accounts, Repo}

  def add_user(first_name, last_name, email, roles \\ []) do
    user = %{first_name: first_name, last_name: last_name, email: email, roles: roles}
    {:ok, user} = Accounts.create_user(user)
    user
  end

  def add_user_confirmed(first_name, last_name, email, roles \\ []) do
    user = add_user(first_name, last_name, email, roles)
    Accounts.update_password(user, %{password: "reallyHard2gue$$"})

    user
    |> change(%{confirmed_at: DateTime.utc_now(), roles: roles})
    |> Repo.update!()
  end

  def add_reset_user(first_name, last_name, email) do
    add_user(first_name, last_name, email)
    |> change(%{confirmed_at: DateTime.utc_now()})
    |> change(%{reset_sent_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  def add_token_conn(conn, user) do
    {:ok, conn, user_token, _} =
      %{conn | secret_key_base: ExBackendWeb.Endpoint.config(:secret_key_base)}
      |> APIAuthPlug.create_token(user, otp_app: :ex_backend)

    # Respond to trigger access token caching
    Plug.Conn.send_resp(conn, 200, "Token created ;)")

    # Create a new connection with access token
    Phoenix.ConnTest.build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", user_token)
  end

  def get_token(conn) do
    conn
    |> get_req_header("authorization")
    |> List.first()
  end
end
