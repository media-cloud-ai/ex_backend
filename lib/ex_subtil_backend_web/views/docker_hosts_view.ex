defmodule ExSubtilBackendWeb.Docker.HostsView do
  use ExSubtilBackendWeb, :view
  alias ExSubtilBackendWeb.Docker.HostsView

  def render("index.json", %{hosts: hosts}) do
    %{
      data: render_many(hosts, HostsView, "host.json"),
      total: length(hosts)
    }
  end

  def render("host.json", %{hosts: host_config}) do
    %{
      hostname: host_config.hostname,
      port: host_config.port
    }
  end
end
