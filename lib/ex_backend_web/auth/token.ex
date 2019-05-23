defmodule ExBackendWeb.Auth.Token do
  @behaviour Phauxth.Token

  alias Phoenix.Token
  alias ExBackendWeb.Endpoint

  @token_salt "KBPzeh/8"

  @impl true
  def sign(data, opts \\ []) do
    Token.sign(Endpoint, @token_salt, data, opts)
  end

  @impl true
  def verify(token, opts \\ []) do
    Token.verify(Endpoint, @token_salt, token, opts)
  end
end
