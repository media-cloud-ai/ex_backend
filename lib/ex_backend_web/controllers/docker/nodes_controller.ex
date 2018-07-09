defmodule ExBackendWeb.Docker.NodesController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index])
  plug(:right_technician_check when action in [:index])

  def index(conn, _) do
    nodes = ExBackend.Docker.Node.list()
    render(conn, "index.json", %{nodes: nodes})
  end
end
