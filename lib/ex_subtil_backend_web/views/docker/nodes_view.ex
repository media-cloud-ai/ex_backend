defmodule ExSubtilBackendWeb.Docker.NodesView do
  use ExSubtilBackendWeb, :view
  alias ExSubtilBackendWeb.Docker.NodesView

  def render("index.json", %{nodes: nodes}) do
    %{
      data: render_many(nodes, NodesView, "node.json"),
      total: length(nodes)
    }
  end

  def render("node.json", %{nodes: node_config}) do
    %{
      label: node_config.label,
      hostname: node_config.hostname,
      port: node_config.port
    }
  end
end
