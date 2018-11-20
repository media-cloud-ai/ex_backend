defmodule ExBackendWeb.DocumentationController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index])
  def index(conn, params) do
    response =
      routes()
      |> format_routes

    conn
    |> json(response)
  end

  defp routes(args \\ []) do
    router(args).__routes__
  end

  defp router(args) do
    Module.concat("ExBackendWeb", "Router")
  end

  defp format_routes(routes, result \\ [])
  defp format_routes([], result), do: result
  defp format_routes([route | routes], result) do
    # IO.inspect(route)
    result = List.insert_at(result, -1, %{
      helper: route.helper,
      path: route.path,
      verb: route.verb
    })
    format_routes(routes, result)
  end
end