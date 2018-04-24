defmodule ExSubtilBackendWeb.AuthCase do
  use Phoenix.ConnTest

  import Ecto.Changeset
  alias ExSubtilBackend.{Accounts, Repo}

  def add_user(email, rights \\ ["administrator"]) do
    user = %{email: email, password: "reallyHard2gue$$", rights: rights}
    {:ok, user} = Accounts.create_user(user)
    user
  end

  def add_user_confirmed(email, rights \\ ["administrator"]) do
    add_user(email)
    |> change(%{confirmed_at: DateTime.utc_now(), rights: rights})
    |> Repo.update!()
  end

  def add_reset_user(email) do
    add_user(email)
    |> change(%{confirmed_at: DateTime.utc_now()})
    |> change(%{reset_sent_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  def add_token_conn(conn, user) do
    user_token = Phauxth.Token.sign(ExSubtilBackendWeb.Endpoint, user.id)

    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", user_token)
  end

  def gen_key(email) do
    Phauxth.Token.sign(ExSubtilBackendWeb.Endpoint, %{"email" => email})
  end
end
