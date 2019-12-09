defmodule ExBackend.Docker.NodeConfig do
  @moduledoc false

  alias ExBackend.Nodes.Node

  def build(hostname, port, cacertfile, certfile, keyfile) do
    case {hostname, port, cacertfile, certfile, keyfile} do
      {nil, nil, nil, nil, nil} ->
        RemoteDockers.NodeConfig.new(hostname)

      {hostname, nil, nil, nil, nil} ->
        RemoteDockers.NodeConfig.new(hostname)

      {hostname, port, nil, nil, nil} ->
        RemoteDockers.NodeConfig.new(hostname, port)

      {hostname, nil, nil, certfile, keyfile} ->
        RemoteDockers.NodeConfig.new(hostname, certfile, keyfile)

      {hostname, port, nil, certfile, keyfile} ->
        RemoteDockers.NodeConfig.new(hostname, port, certfile, keyfile)

      {hostname, nil, cacertfile, certfile, keyfile} ->
        RemoteDockers.NodeConfig.new(hostname, cacertfile, certfile, keyfile)

      {hostname, port, cacertfile, certfile, keyfile} ->
        RemoteDockers.NodeConfig.new(hostname, port, cacertfile, certfile, keyfile)
    end
  end

  def to_node_config(%Node{} = nnode) do
    build(nnode.hostname, nnode.port, nnode.cacertfile, nnode.certfile, nnode.keyfile)
    |> RemoteDockers.NodeConfig.set_label(nnode.label)
  end
end
