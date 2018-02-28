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

  def create(conn, %{"host" => host, "name" => name, "params" => params}) do
    %HostConfig{host: host["host"], port: host["port"], ssl: host["ssl"]}
    |> Containers.create(name, params)
    index(conn, params)
  end

  defp list_containers(%HostConfig{} = host) do
    Containers.list_all(host).body
  end

end
