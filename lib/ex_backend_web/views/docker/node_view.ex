defmodule ExBackendWeb.Docker.NodeView do
  use ExBackendWeb, :view
  alias ExBackendWeb.Docker.NodeView

  def render("index.json", %{nodes: nodes}) do
    %{
      data: render_many(nodes.data, NodeView, "node.json"),
      total: nodes.total
    }
  end

  def render("show.json", %{node: node}) do
    %{data: render_one(node, NodeView, "node.json")}
  end

  def render("node.json", %{node: node_config}) do
    %{
      id: node_config.id,
      label: node_config.label,
      hostname: node_config.hostname,
      port: node_config.port,
      ssl: %{
        certfile: node_config.certfile,
        keyfile: node_config.keyfile,
      },
      inserted_at: node_config.inserted_at,
      updated_at: node_config.updated_at
    }
  end
end
