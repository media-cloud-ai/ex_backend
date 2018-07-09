defmodule ExBackendWeb.ConfirmController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize
  alias ExBackend.Accounts

  def index(conn, params) do
    case Phauxth.Confirm.verify(params, Accounts) do
      {:ok, user} ->
        Accounts.confirm_user(user)
        message = "Your account has been confirmed"
        Accounts.Message.confirm_success(user.email)
        render(conn, ExBackendWeb.ConfirmView, "info.json", %{info: message})

      {:error, _message} ->
        error(conn, :unauthorized, 401)
    end
  end
end
