defmodule ExBackendWeb.PasswordResetController do
  use ExBackendWeb, :controller
  alias ExBackend.Accounts

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    user = Accounts.create_password_reset(%{"email" => email})
    token = ExBackendWeb.Auth.Token.sign(%{"email" => user.email})

    Accounts.Message.reset_request(email, token)
    message = "Check your inbox for instructions on how to reset your password"

    conn
    |> put_status(:created)
    |> render(ExBackendWeb.PasswordResetView, "info.json", %{info: message})
  end

  def update(conn, %{"password_reset" => params}) do
    case ExBackendWeb.Auth.Token.verify(params, mode: :pass_reset) do
      {:ok, user} ->
        Accounts.update_password(user, params) |> update_password(conn, params)

      {:error, message} ->
        put_status(conn, :unprocessable_entity)
        |> render(ExBackendWeb.PasswordResetView, "error.json", error: message)
    end
  end

  defp update_password({:ok, user}, conn, _params) do
    Accounts.Message.reset_success(user.email)
    message = "Your password has been reset"

    render(conn, ExBackendWeb.PasswordResetView, "info.json", %{info: message})
  end

  defp update_password({:error, %Ecto.Changeset{} = changeset}, conn, _params) do
    message = with p <- changeset.errors[:password], do: elem(p, 0)

    put_status(conn, :unprocessable_entity)
    |> render(
      ExBackendWeb.PasswordResetView,
      "error.json",
      error: message || "Invalid input"
    )
  end
end
