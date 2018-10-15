defmodule ExBackendWeb.Docker.ContainersController do
  use ExBackendWeb, :controller
  require Logger

  import ExBackendWeb.Authorize

  alias ExBackend.Nodes
  alias ExBackend.Nodes.Node
  alias RemoteDockers.Container

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :create, :show, :start, :stop])
  plug(:right_technician_check when action in [:index, :create, :show, :start, :stop])

  def index(conn, params) do
    containers = list_all(params)
    render(conn, "index.json", containers: containers)
  end

  def create(conn, params) do
    %{
      "container_name" => container_name,
      "node_id" => node_id,
      "image_parameters" => parameters
    } = params

    node_config =
      Nodes.get_node!(node_id)
      |> ExBackend.Docker.NodeConfig.to_node_config()

    container_config = ExBackend.Docker.Container.build_config(parameters)

    try do
      container = Container.create!(node_config, container_name, container_config)
      render(conn, "container.json", containers: container)
    rescue
      error ->
        Logger.error("#{__MODULE__}: #{inspect(error)}")

        conn
        |> send_resp(:internal_server_error, Exception.message(error))
    end
  end

  def delete(conn, %{"id" => container_id}) do
    get_container(container_id)
    |> case do
      nil ->
        send_resp(conn, :not_found, "unable to find container for ID: " <> container_id)

      container ->
        Container.remove!(container)
        send_resp(conn, :ok, container_id)
    end
  end

  def start(conn, %{"containers_id" => container_id}) do
    get_container(container_id)
    |> case do
      nil ->
        send_resp(conn, :not_found, "unable to find container for ID: " <> container_id)

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
      nil ->
        send_resp(conn, :not_found, "unable to find container for ID: " <> container_id)

      container ->
        Container.stop!(container)
        |> case do
          nil -> send_resp(conn, :not_found, "")
          _ -> render(conn, "container.json", containers: container)
        end
    end
  end

  defp get_container(container_id) do
    list_all()
    |> Enum.find(fn container ->
      container.id == container_id
    end)
  end

  defp list_containers(%Node{} = node_config) do
    node_config
    |> ExBackend.Docker.NodeConfig.to_node_config()
    |> Container.list_all!()
  end

  defp list_all(params \\ %{}) do
    ExBackend.Nodes.list_nodes(params)
    |> Map.get(:data)
    |> Enum.map(fn node_config ->
      list_containers(node_config)
      |> Enum.map(fn container ->
        container
        |> Map.put(:node_id, node_config.id)
      end)
    end)
    |> Enum.concat()
  end
end
