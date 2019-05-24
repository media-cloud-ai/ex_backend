defmodule ExBackendWeb.ConfirmController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize
  alias ExBackend.Accounts

  def index(conn, params) do
    case ExBackendWeb.Auth.Token.verify(params) do
      {:ok, nil} ->
        error(conn, :unauthorized, 401)

      {:ok, user} ->
        case Accounts.update_password(user, params) do
          {:ok, user} ->
            Accounts.confirm_user(user)
            message = "Your account has been confirmed"
            Accounts.Message.confirm_success(user.email)
            render(conn, ExBackendWeb.ConfirmView, "info.json", %{info: message})

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(ExBackendWeb.ChangesetView, "error.json", changeset: changeset)
        end

      {:error, _message} ->
        error(conn, :unauthorized, 401)
    end
  end
end
