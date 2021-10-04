defmodule ExBackendWeb.Auth.Token do
  @behaviour Phauxth.Token
  @moduledoc false

  alias ExBackend.Accounts
  alias ExBackend.Accounts.LoginConfirm
  alias ExBackendWeb.Endpoint
  alias Phoenix.Token

  @token_salt "KBPzeh/8"

  @impl true
  def sign(data, opts \\ []) do
    Token.sign(Endpoint, @token_salt, data, opts)
  end

  @impl true
  def verify(token, opts \\ [])

  @impl true
  def verify(%{"key" => token}, opts) do
    opts = Keyword.put(opts, :max_age, 86_400)

    case Token.verify(Endpoint, @token_salt, token, opts) do
      {:ok, nil} ->
        {:error, "not valid token"}

      {:ok, user_info} ->
        {:ok, Accounts.get_by(user_info)}

      {:error, message} ->
        {:error, message}
    end
  end

  @impl true
  def verify(%{"password" => _password} = params, _opts) do
    LoginConfirm.authenticate(params)
  end

  @impl true
  def verify(%{"access_key_id" => access_key_id, "secret_access_key" => secret_access_key} = params, _opts) do
    LoginConfirm.authenticate_credentials(params)
  end

  @impl true
  def verify(token, opts) do
    Token.verify(Endpoint, @token_salt, token, opts)
  end
end
