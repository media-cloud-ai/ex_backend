defmodule ExSubtilBackendWeb.Docker.NodesController do
  use ExSubtilBackendWeb, :controller

  def index(conn, _) do
    nodes = ExSubtilBackend.Docker.Node.list()
    render(conn, "index.json", %{nodes: nodes})
  end
end
