defmodule ExBackendWeb.Docker.NodeController do
  use ExBackendWeb, :controller
  require Logger
  alias ExBackend.Nodes
  alias ExBackend.Nodes.Node
  import ExBackendWeb.Authorize

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index])
  plug(:right_technician_check when action in [:index])

  def index(conn, _) do
    nodes = Nodes.list_nodes()
    render(conn, "index.json", nodes: nodes)
  end

  def create(conn, %{"node" => node_params}) do
    case Nodes.create_node(node_params) do
      {:ok, %Node{} = node} ->
        conn
        |> put_status(:created)
        |> render("show.json", node: node)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ExBackendWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    node = Nodes.get_node!(id)

    with {:ok, %Node{}} <- Nodes.delete_node(node) do
      send_resp(conn, :no_content, "")
    end
  end

  def test(conn, %{"config" => config}) do
    label = Map.get(config, "label", "")
    hostname = Map.get(config, "hostname")
    port = Map.get(config, "port", 2376)
    certfile = Map.get(config, "certfile")
    keyfile = Map.get(config, "keyfile")

    node_config = ExBackend.Docker.NodeConfig.build(hostname, port, certfile, keyfile)
    node_config = RemoteDockers.NodeConfig.set_label(node_config, label)

    try do
      conn
      |> json(RemoteDockers.Node.info!(node_config))
    rescue
      exception ->
        Logger.error("#{inspect(exception)}")
        send_resp(conn, :not_found, "unable to connect")
    end
  end
end
