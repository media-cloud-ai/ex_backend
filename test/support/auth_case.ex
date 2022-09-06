defmodule ExBackendWeb.AuthCase do
  @moduledoc false

  import Ecto.Changeset
  import Plug.Conn

  alias ExBackendWeb.Auth.Token
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
    user_token = Token.sign(%{"email" => user.email})

    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", user_token)
  end

  def gen_key(email) do
    Token.sign(%{"email" => email})
  end
end
