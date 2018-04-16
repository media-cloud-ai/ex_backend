defmodule ExSubtilBackendWeb.ConfirmController do
  use ExSubtilBackendWeb, :controller

  import ExSubtilBackendWeb.Authorize
  alias ExSubtilBackend.Accounts

  def index(conn, params) do
    case Phauxth.Confirm.verify(params, Accounts) do
      {:ok, user} ->
        Accounts.confirm_user(user)
        message = "Your account has been confirmed"
        Accounts.Message.confirm_success(user.email)
        render(conn, ExSubtilBackendWeb.ConfirmView, "info.json", %{info: message})

      {:error, _message} ->
        error(conn, :unauthorized, 401)
    end
  end
end
