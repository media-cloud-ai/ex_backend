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
    response =
      %HostConfig{host: host["host"], port: host["port"], ssl: host["ssl"]}
      |> Containers.create(name, params)
    render(conn, "creation.json", response: response.body)
  end

  def update(conn, %{"host" => host, "id" => container_id, "action" => action}) do
    hostConfig = %HostConfig{host: host["host"], port: host["port"], ssl: host["ssl"]}
    response =
      case action do
        "start" ->
          Containers.start(hostConfig, container_id)
        "stop" ->
          Containers.start(hostConfig, container_id)
        _ -> nil
      end

    case response do
      nil -> send_resp(conn, :notfound, "")
      _ -> send_resp(conn, :ok, response.body)
    end
  end

  def delete(conn, %{"host" => host, "port" => port, "ssl" => ssl, "id" => container_id}) do
    response =
      %HostConfig{host: host, port: port, ssl: ssl}
      |> Containers.remove(container_id)
    send_resp(conn, :ok, response.body)
  end

  defp list_containers(%HostConfig{} = host) do
    Containers.list_all(host).body
  end

end
