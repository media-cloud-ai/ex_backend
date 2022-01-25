defmodule ExBackendWeb.ConfirmController do
  use ExBackendWeb, :controller

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
            message = "Your account has been confirmed"
            Accounts.Message.confirm_success(user.email)
            render(conn, "info.json", %{info: message})

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
end
