defmodule ExSubtilBackendWeb.Docker.NodesController do
  use ExSubtilBackendWeb, :controller

  def list_nodes() do
    config_nodes = Application.get_env(:ex_subtil_backend, :docker_hosts)
    Enum.map config_nodes, fn host ->

      hostname = Keyword.get(host, :hostname, nil)
      port = Keyword.get(host, :port, nil)
      certfile = Keyword.get(host, :certfile, nil)
      keyfile = Keyword.get(host, :keyfile, nil)

      node_config =
        case {hostname, port, certfile, keyfile} do
          {nil, nil, nil, nil} -> RemoteDockers.NodeConfig.new(hostname)
          {hostname, nil, nil, nil} -> RemoteDockers.NodeConfig.new(hostname)
          {hostname, port, nil, nil} -> RemoteDockers.NodeConfig.new(hostname, port)
          {hostname, nil, certfile, keyfile} -> RemoteDockers.NodeConfig.new(hostname, certfile, keyfile)
          {hostname, port, certfile, keyfile} -> RemoteDockers.NodeConfig.new(hostname, port, certfile, keyfile)
        end

      case Keyword.get(host, :label, nil) do
        nil -> node_config
        label -> RemoteDockers.NodeConfig.set_label(node_config, label)
      end
    end
  end

  def index(conn, _) do
    nodes = list_nodes()
    render(conn, "index.json", %{nodes: nodes})
  end
end
