defmodule ExSubtilBackendWeb.Docker.ContainersController do
  use ExSubtilBackendWeb, :controller
  require Logger

  import ExSubtilBackendWeb.Authorize

  alias ExSubtilBackend.Docker.Node

  alias RemoteDockers.{
    Container,
    NodeConfig
  }

  # the following plugs are defined in the controllers/authorize.ex file
  plug :user_check when action in [:index, :create, :show, :start, :stop]
  plug :id_check when action in [:update, :delete]

  def index(conn, _params) do
    containers = list_all()
    render(conn, "index.json", containers: containers)
  end

  def create(conn, params) do
    %{
      "container_name" => container_name,
      "node_config" => %{
        "label" => label
      },
      "image_parameters" => parameters
    } = params

    node_config = ExSubtilBackend.Docker.Node.get_by_label(label)
    container_config = ExSubtilBackend.Docker.Container.build_config(parameters)

    try do
      container = Container.create!(node_config, container_name, container_config)
      render(conn, "container.json", containers: container)
    rescue
      error ->
        IO.inspect(container_config)
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

  defp list_containers(%NodeConfig{} = node_config) do
    Container.list_all!(node_config)
  end

  defp list_all() do
    Node.list()
    |> Enum.map(fn node_config ->
      list_containers(node_config)
    end)
    |> Enum.concat()
  end
end
