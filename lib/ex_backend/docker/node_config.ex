defmodule ExBackend.Docker.NodeConfig do
  alias ExBackend.Nodes.Node

  def build(hostname, port, certfile, keyfile) do
    case {hostname, port, certfile, keyfile} do
      {nil, nil, nil, nil} ->
        RemoteDockers.NodeConfig.new(hostname)

      {hostname, nil, nil, nil} ->
        RemoteDockers.NodeConfig.new(hostname)

      {hostname, port, nil, nil} ->
        RemoteDockers.NodeConfig.new(hostname, port)

      {hostname, nil, certfile, keyfile} ->
        RemoteDockers.NodeConfig.new(hostname, certfile, keyfile)

      {hostname, port, certfile, keyfile} ->
        RemoteDockers.NodeConfig.new(hostname, port, certfile, keyfile)
    end
  end

  def to_node_config(%Node{} = nnode) do
    build(nnode.hostname, nnode.port, nnode.certfile, nnode.keyfile)
    |> RemoteDockers.NodeConfig.set_label(nnode.label)
  end
end
