defmodule ExSubtilBackendWeb.Docker.HostsView do
  use ExSubtilBackendWeb, :view
  alias ExSubtilBackendWeb.Docker.HostsView

  def render("index.json", %{hosts: hosts}) do
    %{
      data: render_many(hosts, HostsView, "host.json"),
      total: length(hosts)
    }
  end

  def render("host.json", %{hosts: host}) do
    %{
      host: host.host,
      port: host.port,
      ssl: host.ssl
    }
  end
end
