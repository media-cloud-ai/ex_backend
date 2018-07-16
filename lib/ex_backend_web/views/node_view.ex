defmodule ExBackendWeb.NodeView do
  use ExBackendWeb, :view
  alias ExBackendWeb.NodeView

  def render("index.json", %{nodes: %{data: nodes, total: total}}) do
    %{
      data: render_many(nodes, NodeView, "node.json"),
      total: total
    }
  end

  def render("show.json", %{node: nnode}) do
    %{data: render_one(nnode, NodeView, "node.json")}
  end

  def render("node.json", %{node: nnode}) do
    %{
      id: nnode.id,
      label: nnode.label,
      hostname: nnode.hostname,
      port: nnode.port,
      inserted_at: nnode.inserted_at,
      updated_at: nnode.updated_at
    }
  end
end
