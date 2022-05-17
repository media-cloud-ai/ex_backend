defmodule ExBackendWeb.ConfirmController do
  use ExBackendWeb, :controller

  require Logger

  import ExBackendWeb.Authorize
  alias ExBackend.Accounts
  alias ExBackendWeb.Auth.Token

  def index(conn, params) do
    case Token.verify(params) do
      {:ok, nil} ->
        error(conn, :unauthorized, 401)

      {:ok, user} ->
        case Accounts.update_password(user, params) do
          {:ok, user} ->
            Accounts.confirm_user(user)
            send_confirmation_email(conn, user)
            render(conn, "info.json", %{info: "Your account has been confirmed"})

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(ExBackendWeb.ChangesetView)
            |> render("error.json", changeset: changeset)
        end

      {:error, _message} ->
        error(conn, :unauthorized, 401)
    end
  end

  defp send_confirmation_email(conn, user) do
    message = "Your account has been confirmed"

    case Accounts.Message.confirm_success(user.email) do
      {:ok, _sent_mail} ->
        render(conn, "info.json", %{info: message})

      {:error, error} ->
        Logger.error("Email delivery failure: #{inspect(error)}")

        conn
        |> send_resp(500, "Internal Server Error")
    end
  end
end
