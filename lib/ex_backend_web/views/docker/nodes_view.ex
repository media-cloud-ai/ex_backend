defmodule ExBackendWeb.Docker.NodesView do
  use ExBackendWeb, :view
  alias ExBackendWeb.Docker.NodesView

  def render("index.json", %{nodes: nodes}) do
    %{
      data: render_many(nodes, NodesView, "node.json"),
      total: length(nodes)
    }
  end

  def render("node.json", %{nodes: node_config}) do
    ssl =
      case node_config.ssl do
        [certfile: certfile, keyfile: keyfile] ->
          %{
            cert_file: certfile,
            key_file: keyfile
          }
        _ -> %{}
      end

    %{
      label: node_config.label,
      hostname: node_config.hostname,
      port: node_config.port,
      ssl: ssl
    }
  end
end
