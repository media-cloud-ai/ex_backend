defmodule ExBackendWeb.ConfirmController do
  use ExBackendWeb, :controller

  require Logger

  import ExBackendWeb.Authorize
  alias ExBackend.Accounts
  alias ExBackendWeb.Auth.APIAuthPlug

  def index(conn, params) do
    token = Map.get(params, "key")

    config = Pow.Plug.fetch_config(conn)

    case conn
         |> assign(:token, token)
         |> APIAuthPlug.fetch(config) do
      {conn, nil} ->
        error(conn, :unauthorized, 401)

      {conn, user} ->
        case Accounts.update_password(user, params) do
          {:ok, user} ->
            Accounts.confirm_user(user)

            send_confirmation_email(user)
            render(conn, "info.json", %{info: "Your account has been confirmed"})

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(ExBackendWeb.ChangesetView)
            |> render("error.json", changeset: changeset)
        end
    end
  end

  defp send_confirmation_email(user) do
    case Accounts.Message.confirm_success(user.email) do
      {:ok, _sent_mail} ->
        Logger.info("Email delivery success")

      {:error, error} ->
        Logger.error("Email delivery failure: #{inspect(error)}")
    end
  end
end
