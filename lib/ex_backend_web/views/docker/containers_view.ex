defmodule ExBackendWeb.Docker.ContainersView do
  use ExBackendWeb, :view
  alias ExBackendWeb.Docker.ContainersView

  def render("index.json", %{containers: containers}) do
    %{
      data: render_many(containers, ContainersView, "container.json"),
      total: length(containers)
    }
  end

  def render("container.json", %{containers: container}) do
    node_config = %{
      hostname: container.node_config.hostname,
      port: container.node_config.port
    }

    node_config =
      case container.node_config.label do
        nil -> node_config
        label -> Map.put(node_config, :label, label)
      end

    node_config =
      case container.node_config.ssl do
        nil ->
          node_config

        ssl ->
          ssl = %{
            certfile: Keyword.get(ssl, :certfile),
            keyfile: Keyword.get(ssl, :keyfile)
          }

          Map.put(node_config, :ssl, ssl)
      end

    %{
      id: container.id,
      names: container.names,
      image: container.image,
      state: container.state,
      status: container.status,
      node_config: node_config
    }
  end

  def render("creation.json", %{response: response}) do
    %{
      id: response["Id"],
      message: response["message"],
      warning: response["Warnings"]
    }
  end
end
