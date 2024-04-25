defmodule ExBackendWeb.Auth.APIRequireAuthenticatedPlug do
  @moduledoc """
  Extends `Pow.Plug.RequireAuthenticated` for custom authentication check

  This plug ensures that a user has been authenticated.

  You can see `Pow.Phoenix.PlugErrorHandler` for an example of the error
  handler module.

  ## Example

      plug Pow.Plug.RequireAuthenticated,
        error_handler: MyApp.CustomErrorHandler
  """
  alias ExBackendWeb.Auth.APIAuthPlug
  alias Plug.Conn
  alias Pow.Config

  @doc false
  @spec init(Config.t()) :: atom()
  def init(config) do
    Config.get(config, :error_handler) || raise_no_error_handler!()
  end

  @doc false
  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, handler) do
    config = [max_age: 14_400]

    {conn, user} = APIAuthPlug.fetch(conn, config)

    conn
    |> Conn.assign(:current_user, user)
    |> maybe_halt(handler)
  end

  defp maybe_halt(%Conn{assigns: %{current_user: nil}} = conn, handler) do
    conn
    |> handler.call(:not_authenticated)
    |> Conn.halt()
  end

  defp maybe_halt(%Conn{assigns: %{current_user: _user}} = conn, _handler), do: conn

  @spec raise_no_error_handler!() :: no_return()
  defp raise_no_error_handler!,
    do:
      Config.raise_error(
        "No :error_handler configuration option provided. It's required to set this when using #{inspect(__MODULE__)}."
      )
end
