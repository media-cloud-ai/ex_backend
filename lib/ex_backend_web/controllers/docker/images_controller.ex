defmodule ExBackendWeb.Docker.ImagesController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize
  alias ExBackend.Nodes.Node
  alias RemoteDockers.Image

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :delete])
  plug(:right_technician_check when action in [:index, :delete])

  def index(conn, params) do
    hostname = System.get_env("DOCKER_CONTAINER_AMQP_HOSTNAME") || Application.get_env(:docker_container_amqp, :hostname)
    username = System.get_env("DOCKER_CONTAINER_AMQP_USERNAME") || Application.get_env(:docker_container_amqp, :username)
    password = System.get_env("DOCKER_CONTAINER_AMQP_PASSWORD") || Application.get_env(:docker_container_amqp, :password)
    backend_hostname = System.get_env("DOCKER_CONTAINER_BACKEND_HOSTNAME") || Application.get_env(:docker_container_backend, :hostname)
    backend_username = System.get_env("DOCKER_CONTAINER_BACKEND_USERNAME") || Application.get_env(:docker_container_backend, :username)
    backend_password = System.get_env("DOCKER_CONTAINER_BACKEND_PASSWORD") || Application.get_env(:docker_container_backend, :password)

    virtual_host =
      System.get_env("DOCKER_CONTAINER_AMQP_VHOST") || Application.get_env(:docker_container_amqp, :virtual_host) || "/"

    mounted_workdir = Application.get_env(:ex_backend, :mounted_workdir, "/data")
    workdir = Application.get_env(:ex_backend, :workdir, "/data")

    mounted_appdir = Application.get_env(:ex_backend, :mounted_appdir, "/opt/app")
    appdir = Application.get_env(:ex_backend, :appdir)

    volumes = [
      %{
        host: mounted_workdir,
        container: workdir
      },
      %{
        host: mounted_appdir,
        container: appdir
      }
    ]

    environment = %{
      AMQP_HOSTNAME: hostname,
      AMQP_USERNAME: username,
      AMQP_PASSWORD: password,
      AMQP_VHOST: virtual_host,
      BACKEND_HOSTNAME: backend_hostname,
      BACKEND_USERNAME: backend_username,
      BACKEND_PASSWORD: backend_password,
    }

    image_list =
      list_all(params)
      |> build_images(environment, volumes)

    conn
    |> json(%{data: image_list})
  end

  def update(conn, %{"id" => id, "node_id" => node_id}) do
    image =
      list_all(%{"node_id" => node_id})
      |> Enum.filter(fn image ->
          image.id == id
        end)
      |> List.first()

    tag =
      image.repo_tags
      |> List.first()

    response = Image.pull!(image.node_config, tag)

    conn
    |> json(%{data: response})
  end

  def delete(conn, %{"id" => id, "node_id" => node_id}) do
    image =
      list_all(%{"node_id" => node_id})
      |> Enum.filter(fn image ->
          image.id == id
        end)
      |> List.first()

    try do
      Image.delete!(image)
      send_resp(conn, :no_content, "")
    rescue
      e ->
        send_resp(conn, :forbidden, e.message)
    end
  end

  defp build_images(images, environment, volumes, image_list \\ [])
  defp build_images([], _environment, _volumes, image_list), do: image_list

  defp build_images([image | images], environment, volumes, image_list) do
    image_environment =
      if image.repo_tags && Enum.any?(image.repo_tags, fn tag -> String.starts_with?(tag, "ftvsubtil/acs_worker") end) do
        Map.put(environment, :AMQP_QUEUE, "acs")
      else
        environment
      end

    configuration = %{
      id: image.id,
      node_config: %{
        label: image.node_config.label
      },
      node_id: image.node_id,
      size: image.size,
      params: %{
        image: get_tag(image.repo_tags),
        environment: image_environment,
        volumes: volumes
      }
    }

    image_list = List.insert_at(image_list, -1, configuration)
    build_images(images, environment, volumes, image_list)
  end

  defp get_tag(nil), do: "Unknown"
  defp get_tag([]), do: ""
  defp get_tag(tags) do
    List.first(tags)
  end

  defp list_images(%Node{} = node_config) do
    node_config
    |> ExBackend.Docker.NodeConfig.to_node_config()
    |> Image.list_all!()
  end

  defp list_all(params) do
    node_id =
      Map.get(params, "node_id")
      |> case do
        nil -> nil
        node_id -> force_integer(node_id)
      end

    ExBackend.Nodes.list_nodes()
    |> Map.get(:data)
    |> Enum.filter(fn node ->
      case node_id do
        nil -> true
        _ -> node_id == node.id
      end
      end)
    |> Enum.map(fn node_config ->
      list_images(node_config)
      |> Enum.map(fn image ->
        image
        |> Map.put(:node_id, node_config.id)
      end)
    end)
    |> Enum.concat()
  end

  defp force_integer(param) when is_bitstring(param) do
    param
    |> String.to_integer()
  end

  defp force_integer(param) do
    param
  end
end
