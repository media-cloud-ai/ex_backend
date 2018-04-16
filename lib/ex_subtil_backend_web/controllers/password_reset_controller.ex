defmodule ExSubtilBackendWeb.PasswordResetController do
  use ExSubtilBackendWeb, :controller
  alias ExSubtilBackend.Accounts

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    key = Accounts.create_password_reset(ExSubtilBackendWeb.Endpoint, %{"email" => email})
    Accounts.Message.reset_request(email, key)
    message = "Check your inbox for instructions on how to reset your password"

    conn
    |> put_status(:created)
    |> render(ExSubtilBackendWeb.PasswordResetView, "info.json", %{info: message})
  end

  def update(conn, %{"password_reset" => params}) do
    case Phauxth.Confirm.verify(params, Accounts, mode: :pass_reset) do
      {:ok, user} ->
        Accounts.update_password(user, params) |> update_password(conn, params)

      {:error, message} ->
        put_status(conn, :unprocessable_entity)
        |> render(ExSubtilBackendWeb.PasswordResetView, "error.json", error: message)
    end
  end

  defp update_password({:ok, user}, conn, _params) do
    Accounts.Message.reset_success(user.email)
    message = "Your password has been reset"

    render(conn, ExSubtilBackendWeb.PasswordResetView, "info.json", %{info: message})
  end

  defp update_password({:error, %Ecto.Changeset{} = changeset}, conn, _params) do
    message = with p <- changeset.errors[:password], do: elem(p, 0)

    put_status(conn, :unprocessable_entity)
    |> render(
      ExSubtilBackendWeb.PasswordResetView,
      "error.json",
      error: message || "Invalid input"
    )
  end
end
