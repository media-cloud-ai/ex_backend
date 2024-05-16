defmodule ExBackendWeb.Auth.Token do
  @moduledoc false

  alias ExBackend.Accounts.User

  def generate(conn, config) do
    uuid = Pow.UUID.generate()

    signed_token = sign(conn, uuid, config)

    {uuid, signed_token}
  end

  def sign(conn, data, config) do
    conn
    |> sign_token(data, config)
  end

  @doc """
  Retrieve user from token
  """
  def verify(conn, token, opts \\ [])

  def verify(conn, %{"key" => token}, opts) do
    opts = Keyword.put(opts, :max_age, 86_400)

    verify_token(conn, token, opts)
  end

  def verify(
        _conn,
        %{"access_key_id" => _access_key_id, "secret_access_key" => _secret_access_key} = params,
        _opts
      ) do
    verify_access_key(params)
  end

  def verify(conn, token, opts), do: verify_token(conn, token, opts)

  defp signing_salt, do: Atom.to_string(__MODULE__)

  def sign_token(conn, token, config) do
    Pow.Plug.sign_token(conn, signing_salt(), token, config)
  end

  def fetch_access_token(%{assigns: %{token: token}}) do
    {:ok, token}
  end

  def fetch_access_token(conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      [token | _rest] ->
        {:ok, token}

      _any ->
        :error
    end
  end

  def verify_token(conn, token, config \\ [])

  def verify_token(%Phoenix.Socket{} = socket, token, config) do
    socket
    |> Map.put(:secret_key_base, ExBackendWeb.Endpoint.config(:secret_key_base))
    |> Pow.Plug.verify_token(signing_salt(), token, config)
  end

  def verify_token(conn, token, config) do
    Pow.Plug.verify_token(conn, signing_salt(), token, config)
  end

  defp verify_access_key(%{
         "access_key_id" => access_key_id,
         "secret_access_key" => secret_access_key
       }) do
    case User.get_by(%{"access_key_id" => access_key_id}) do
      nil ->
        {:error, "no user found"}

      user ->
        if User.verify_secret_access_key(user, secret_access_key) == true do
          {:ok, user}
        else
          {:error, "bad password"}
        end
    end
  end

  def store_config(config) do
    backend = Pow.Config.get(config, :cache_store_backend, Pow.Store.Backend.EtsCache)

    [backend: backend, pow_config: config]
  end
end
