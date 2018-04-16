defmodule ExSubtilBackendWeb.Docker.NodesController do
  use ExSubtilBackendWeb, :controller

  import ExSubtilBackendWeb.Authorize

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index])

  def index(conn, _) do
    nodes = ExSubtilBackend.Docker.Node.list()
    render(conn, "index.json", %{nodes: nodes})
  end
end
