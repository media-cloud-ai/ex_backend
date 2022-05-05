defmodule ExBackendWeb.Auth.TokenCookie do
  use Phauxth.Authenticate.Token

  @moduledoc false

  @impl true
  def authenticate(%Plug.Conn{req_cookies: %{"token" => token}}, user_context, opts) do
    verify_token(token, user_context, opts)
  end

  @impl true
  def authenticate(conn, user_context, opts) do
    case get_req_header(conn, "authorization") do
      [] ->
        {:error, "No access token cookie"}

      ["Bearer " <> token] ->
        verify_token(token, user_context, opts)

      [token] ->
        verify_token(token, user_context, opts)
    end
  end
end
