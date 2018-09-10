defmodule ExBackendWeb.RegisteryController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  alias ExBackend.Registeries

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index])
  plug(:right_editor_check when action in [:index])

  def index(conn, params) do
    items = Registeries.list_registeries(params)
    render(conn, "index.json", items: items)
  end

  def show(conn, %{"id" => id}) do
    item = Registeries.get_registery!(id)
    render(conn, "show.json", item: item)
  end
end
