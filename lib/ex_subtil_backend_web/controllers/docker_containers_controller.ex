defmodule ExSubtilBackendWeb.Docker.ContainersController do
  use ExSubtilBackendWeb, :controller

  alias ExSubtilBackendWeb.Docker.HostsController
  alias RemoteDockers.{
    Container,
    ContainerConfig,
    DockerHostConfig
  }

  def index(conn, _params) do
    containers = list_all()
    render(conn, "index.json", containers: containers)
  end


  def create(conn, %{"docker_host_config" => docker_host_config, "container_name" => container_name, "container_config" => container_config}) do
    docker_host_config =
      docker_host_config
      |> to_struct(DockerHostConfig)
    container_config =
      container_config
      |> to_struct(ContainerConfig)

    create(conn, docker_host_config, container_name, container_config)
  end

  def create(conn, %DockerHostConfig{} = docker_host_config, container_name, %ContainerConfig{} = container_config) do
    container =
      try do
        Container.create!(docker_host_config, container_name, container_config)
      rescue
        error ->
          conn
          |> send_resp(:internal_server_error, Exception.message(error))
          |> halt
      end
    render(conn, "container.json", containers: container)
  end


  def delete(conn, %{"id" => container_id}) do
    get_container(container_id)
    |> case do
      nil -> send_resp(conn, :not_found, "unable to find container for ID: " <> container_id)
      container ->
        Container.remove!(container)
        send_resp(conn, :ok, container_id)
    end
  end


  def start(conn, %{"containers_id" => container_id}) do
    get_container(container_id)
    |> case do
      nil -> send_resp(conn, :not_found, "unable to find container for ID: " <> container_id)
      container ->
        Container.start!(container)
        |> case do
          nil -> send_resp(conn, :not_found, "")
          _ -> render(conn, "container.json", containers: container)
        end
    end
  end

  def stop(conn, %{"containers_id" => container_id}) do
    get_container(container_id)
    |> case do
      nil -> send_resp(conn, :not_found, "unable to find container for ID: " <> container_id)
      container ->
        Container.stop!(container)
        |> case do
          nil -> send_resp(conn, :not_found, "")
          _ -> render(conn, "container.json", containers: container)
        end
    end
  end

  defp to_struct(map, type) do
    struct = struct(type)
    Map.to_list(struct)
    |> Enum.reduce(struct, fn {key, _}, acc ->
      case Map.fetch(map, Atom.to_string(key)) do
        {:ok, value} -> %{acc | key => value}
        :error -> acc
      end
    end)
  end

  defp get_container(container_id) do
    list_all()
    |> Enum.find(fn(container) ->
      container.id == container_id
    end)
  end

  defp list_containers(%DockerHostConfig{} = host) do
    Container.list_all!(host)
  end

  defp list_all() do
    HostsController.list_hosts()
    |> Enum.map(fn(docker_host) ->
        list_containers(docker_host)
      end)
    |> Enum.concat
  end


end
