defmodule ExBackendWeb.Auth.TokenCookie do
  use Phauxth.Authenticate.Token

  @impl true
  def authenticate(%Plug.Conn{req_cookies: %{"token" => token}}, user_context, opts) do
    verify_token(token, user_context, opts)
  end

  @impl true
  def authenticate(_conn, _user_context, _opts) do
    {:error, "No access token cookie"}
  end
end
