defmodule ExSubtilBackendWeb.Docker.ImagesController do
  use ExSubtilBackendWeb, :controller

  alias ExSubtilBackend.Docker.Node
  alias RemoteDockers.{
    Image,
    NodeConfig
  }

  def index(conn, _params) do
    hostname = System.get_env("AMQP_HOSTNAME") || Application.get_env(:amqp, :hostname)
    username = System.get_env("AMQP_USERNAME") || Application.get_env(:amqp, :username)
    password = System.get_env("AMQP_PASSWORD") || Application.get_env(:amqp, :password)
    virtual_host = System.get_env("AMQP_VHOST") || Application.get_env(:amqp, :virtual_host) || "/"
    mounted_workdir = Application.get_env(:ex_subtil_backend, :mounted_workdir, "/data")
    workdir = Application.get_env(:ex_subtil_backend, :workdir)

    mounted_appdir = Application.get_env(:ex_subtil_backend, :mounted_workdir, "/app")
    appdir = Application.get_env(:ex_subtil_backend, :appdir)

    volumes = [
      %{
        "host": mounted_workdir,
        "container": workdir,
      },
      %{
        "host": mounted_appdir,
        "container": appdir,
      }
    ]

    environment = %{
      "AMQP_HOSTNAME": hostname,
      "AMQP_USERNAME": username,
      "AMQP_PASSWORD": password,
      "AMQP_VHOST": virtual_host
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
    configuration = %{
      "id": image.id,
      "node_config": %{
        "label": image.node_config.label
      },
      "params": %{
        "image": image.repo_tags |> List.first,
        "environment": environment,
        "volumes": volumes
      }
    }

    image_list = List.insert_at(image_list, -1, configuration)
    build_images(images, environment, volumes, image_list)
  end

  defp list_images(%NodeConfig{} = node_config) do
    Image.list_all!(node_config)
  end

  defp list_all() do
    Node.list()
    |> Enum.map(fn(node_config) ->
        list_images(node_config)
      end)
    |> Enum.concat
  end
end
