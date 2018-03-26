defmodule ExSubtilBackendWeb.Docker.ImagesController do
  use ExSubtilBackendWeb, :controller

  def index(conn, _params) do

    hostname = System.get_env("AMQP_HOSTNAME") || Application.get_env(:amqp, :hostname)
    username = System.get_env("AMQP_USERNAME") || Application.get_env(:amqp, :username)
    password = System.get_env("AMQP_PASSWORD") || Application.get_env(:amqp, :password)
    virtual_host = System.get_env("AMQP_VHOST") || Application.get_env(:amqp, :virtual_host) || "/"
    mounted_workdir = Application.get_env(:ex_subtil_backend, :mounted_workdir, "/data")
    workdir = Application.get_env(:ex_subtil_backend, :workdir)
    images = Application.get_env(:ex_subtil_backend, :images, [])

    volumes = [
      %{
        "host": mounted_workdir,
        "container": workdir,
      }
    ]

    environment = %{
      "AMQP_HOSTNAME": hostname,
      "AMQP_USERNAME": username,
      "AMQP_PASSWORD": password,
      "AMQP_VHOST": virtual_host
    }

    image_list =
      []
      |> add_image(images, environment, volumes, "file_system")
      |> add_image(images, environment, volumes, "ftp")
      |> add_image(images, environment, volumes, "gpac")
      |> add_image(images, environment, volumes, "http")

    conn
    |> json(%{data: image_list})
  end

  defp get_image_name(images, name) do
    worker_version = Keyword.get(images, name <> "_worker_version" |> String.to_atom , "latest")
    "ftvsubtil/" <> name <> "_worker:" <> worker_version
  end

  defp add_image(image_list, images, environment, volumes, name) do
    image = %{
      "id": get_image_name(images, name) |> String.replace(":", "_") |> String.replace("/", "_"),
      "params": %{
        "image": get_image_name(images, name),
        "environment": environment,
        "volumes": volumes
      }
    }
    List.insert_at(image_list, -1, image)
  end
end
