defmodule ExBackend.Docker.Node do
  def list() do
    config_nodes = Application.get_env(:ex_backend, :docker_hosts)

    Enum.map(config_nodes, fn host ->
      hostname = Keyword.get(host, :hostname, nil)
      port = Keyword.get(host, :port, nil)
      certfile = Keyword.get(host, :certfile, nil)
      keyfile = Keyword.get(host, :keyfile, nil)

      node_config =
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

      case Keyword.get(host, :label, nil) do
        nil -> node_config
        label -> RemoteDockers.NodeConfig.set_label(node_config, label)
      end
    end)
  end

  def get_by_label(label) do
    one_by_label(list(), label)
  end

  defp one_by_label([], _label), do: nil

  defp one_by_label([config | configs], label) do
    if config.label == label do
      config
    else
      one_by_label(configs, label)
    end
  end
end
