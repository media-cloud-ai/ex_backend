defmodule ExBackend.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :ex_backend,
    adapter: Ecto.Adapters.Postgres

  require Logger

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    case System.get_env("DATABASE_URL") do
      nil ->
        opts =
          opts
          |> get_hostname()
          |> get_database_port()
          |> get_database_username()
          |> get_database_password()
          |> get_database_name()

        Logger.debug("Backend connecting to Postgres with parameters: #{inspect(opts)}")
        {:ok, opts}

      url ->
        Logger.debug("Backend connecting to Postgres with parameters: #{url}")
        {:ok, Keyword.put(opts, :url, url)}
    end
  end

  def get_hostname(opts) do
    case System.get_env("DATABASE_HOSTNAME") do
      nil ->
        opts

      hostname ->
        Keyword.put(opts, :hostname, hostname)
    end
  end

  def get_database_port(opts) do
    case System.get_env("DATABASE_PORT") do
      nil ->
        opts

      port ->
        Keyword.put(opts, :port, port)
    end
  end

  def get_database_username(opts) do
    case System.get_env("DATABASE_USERNAME") do
      nil ->
        opts

      username ->
        Keyword.put(opts, :username, username)
    end
  end

  def get_database_password(opts) do
    case System.get_env("DATABASE_PASSWORD") do
      nil ->
        opts

      password ->
        Keyword.put(opts, :password, password)
    end
  end

  def get_database_name(opts) do
    case System.get_env("DATABASE_NAME") do
      nil ->
        opts

      database ->
        Keyword.put(opts, :database, database)
    end
  end
end
