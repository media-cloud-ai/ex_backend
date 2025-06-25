defmodule ExBackendWeb.Auth.APIAuthPlug do
  @moduledoc false
  use Pow.Plug.Base

  alias ExBackendWeb.Auth.Token
  alias Plug.Conn
  alias Pow.{Config, Store.CredentialsCache}
  alias PowPersistentSession.Store.PersistentSessionCache

  @doc """
  Fetches the user from access token.
  """
  @impl true
  @spec fetch(Conn.t(), Config.t()) :: {Conn.t(), map() | nil}
  def fetch(conn, config) do
    with {:ok, signed_token} <- Token.fetch_access_token(conn),
         {:ok, token} <- Token.verify_token(conn, signed_token, config),
         {user, _metadata} <- CredentialsCache.get(Token.store_config(config), token) do
      {conn, user}
    else
      _any -> {conn, nil}
    end
  end

  @doc """
  Creates an access and renewal token for the user.

  The tokens are added to the `conn.private` as `:api_access_token` and
  `:api_renewal_token`. The renewal token is stored in the access token
  metadata and vice versa.
  """
  @impl true
  @spec create(Conn.t(), map(), Config.t()) :: {Conn.t(), map()}
  def create(conn, user, config) do
    case create_token(conn, user, config) do
      {:ok, conn, _, _} -> {conn, user}
      _ -> {conn, nil}
    end
  end

  def create_token(conn, user), do: create_token(conn, user, Pow.Plug.fetch_config(conn))

  def create_token(conn, user, config) do
    store_config = Token.store_config(config)

    {access_token, signed_access_token} = Token.generate(conn, config)
    {renewal_token, signed_renewal_token} = Token.generate(conn, config)

    conn =
      conn
      |> Conn.put_private(:api_access_token, signed_access_token)
      |> Conn.put_private(:api_renewal_token, signed_renewal_token)
      |> Conn.put_private(:pow_assent_session_info, :write)
      |> Conn.register_before_send(fn conn ->
        # The store caches will use their default `:ttl` setting. To change the
        # `:ttl`, `Keyword.put(store_config, :ttl, :timer.minutes(10))` can be
        # passed in as the first argument instead of `store_config`.
        CredentialsCache.put(
          Keyword.put(store_config, :ttl, :timer.hours(6)),
          access_token,
          {user, [renewal_token: renewal_token]}
        )

        PersistentSessionCache.put(
          Keyword.put(store_config, :ttl, :timer.hours(6)),
          renewal_token,
          {user, [access_token: access_token]}
        )

        conn
      end)

    {:ok, conn, signed_access_token, signed_renewal_token}
  end

  @doc """
  Delete the access token from the cache.

  The renewal token is deleted by fetching it from the access token metadata.
  """
  @impl true
  @spec delete(Conn.t(), Config.t()) :: Conn.t()
  def delete(conn, config) do
    store_config = Token.store_config(config)

    with {:ok, signed_token} <- Token.fetch_access_token(conn),
         {:ok, token} <- Token.verify_token(conn, signed_token, config),
         {_user, metadata} <- CredentialsCache.get(store_config, token) do
      Conn.register_before_send(conn, fn conn ->
        PersistentSessionCache.delete(store_config, metadata[:renewal_token])
        CredentialsCache.delete(store_config, token)

        conn
      end)
    else
      _any -> conn
    end
  end

  @doc """
  Creates new tokens using the renewal token.

  The access token, if any, will be deleted by fetching it from the renewal
  token metadata. The renewal token will be deleted from the store after the
  it has been fetched.
  """
  @spec renew(Conn.t(), Config.t()) :: {Conn.t(), map() | nil}
  def renew(conn, config) do
    store_config = Token.store_config(config)

    with {:ok, signed_token} <- Token.fetch_access_token(conn),
         {:ok, token} <- Token.verify_token(conn, signed_token, config),
         {user, metadata} <- PersistentSessionCache.get(store_config, token) do
      {conn, user} = create(conn, user, config)

      conn =
        Conn.register_before_send(conn, fn conn ->
          CredentialsCache.delete(store_config, metadata[:access_token])
          PersistentSessionCache.delete(store_config, token)

          conn
        end)

      {conn, user}
    else
      _any -> {conn, nil}
    end
  end
end
