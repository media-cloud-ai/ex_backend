defmodule ExBackendWeb.Docker.ImagesController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize
  alias ExBackend.Nodes.Node
  alias RemoteDockers.Image

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index])
  plug(:right_technician_check when action in [:index])

  def index(conn, _params) do
    hostname = System.get_env("AMQP_HOSTNAME") || Application.get_env(:amqp, :hostname)
    username = System.get_env("AMQP_USERNAME") || Application.get_env(:amqp, :username)
    password = System.get_env("AMQP_PASSWORD") || Application.get_env(:amqp, :password)

    virtual_host =
      System.get_env("AMQP_VHOST") || Application.get_env(:amqp, :virtual_host) || "/"

    mounted_workdir = Application.get_env(:ex_backend, :mounted_workdir, "/data")
    workdir = Application.get_env(:ex_backend, :workdir)

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
      AMQP_VHOST: virtual_host
    }

    image_list =
      list_all()
      |> build_images(environment, volumes)

    conn
    |> json(%{data: image_list})
  end

  defp build_images(images, environment, volumes, image_list \\ [])
  defp build_images([], _environment, _volumes, image_list), do: image_list
  defp build_images([image | images], environment, volumes, image_list) do
    image_environment =
      if Enum.any?(image.repo_tags, fn(tag) -> String.starts_with?(tag, "ftvsubtil/acs_worker") end) do
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
      params: %{
        image: image.repo_tags |> List.first(),
        environment: image_environment,
        volumes: volumes
      }
    }

    image_list = List.insert_at(image_list, -1, configuration)
    build_images(images, environment, volumes, image_list)
  end

  defp list_images(%Node{} = node_config) do
    node_config
    |> ExBackend.Docker.NodeConfig.to_node_config()
    |> Image.list_all!()
  end

  defp list_all() do
    ExBackend.Nodes.list_nodes()
    |> Map.get(:data)
    |> Enum.map(fn node_config ->
      list_images(node_config)
      |> Enum.map(fn image ->
        image
        |> Map.put(:node_id, node_config.id)
      end)
    end)
    |> Enum.concat()
  end
end
