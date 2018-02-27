defmodule ExSubtilBackendWeb.Docker.ContainersController do
  use ExSubtilBackendWeb, :controller

  alias ExSubtilBackendWeb.Docker.HostsController
  alias ExRemoteDockers.Containers
  alias ExRemoteDockers.HostConfig

  def index(conn, _params) do
    containers =
      HostsController.list_hosts()
      |> Enum.map(fn(host) ->
          list_containers(host)
          |> Enum.map(fn(container) ->
              container
              |> Map.put("Host", host)
            end)
        end)
      |> Enum.concat
    render(conn, "index.json", containers: containers)
  end

  def list_containers(%HostConfig{} = host) do
    Containers.list(host).body
  end

end
