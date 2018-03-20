defmodule ExSubtilBackendWeb.Docker.ImagesController do
  use ExSubtilBackendWeb, :controller

  def index(conn, _params) do

    hostname = System.get_env("AMQP_HOSTNAME") || Application.get_env(:amqp, :hostname)
    username = System.get_env("AMQP_USERNAME") || Application.get_env(:amqp, :username)
    password = System.get_env("AMQP_PASSWORD") || Application.get_env(:amqp, :password)
    virtual_host = System.get_env("AMQP_VHOST") || Application.get_env(:amqp, :virtual_host) || "/"
    workdir = Application.get_env(:ex_subtil_backend, :workdir)

    volumes = [
      %{
        "host": "/data",
        "container": workdir,
      }
    ]

    images = [
      %{
        "id": "gpac-worker",
        "label": "GPAC Worker",
        "params": %{
          "image": "ftvsubtil/gpac_worker",
          "environment": %{
            "AMQP_HOSTNAME": hostname,
            "AMQP_USERNAME": username,
            "AMQP_PASSWORD": password,
            "AMQP_VHOST": virtual_host
          },
          "volumes": volumes
        }
      },
      %{
        "id": "ftp-worker",
        "label": "FTP Worker",
        "params": %{
          "image": "ftvsubtil/ftp_worker",
          "environment": %{
            "AMQP_HOSTNAME": hostname,
            "AMQP_USERNAME": username,
            "AMQP_PASSWORD": password,
            "AMQP_VHOST": virtual_host
          },
          "volumes": volumes
        }
      },
      %{
        "id": "http-worker",
        "label": "HTTP Worker",
        "params": %{
          "image": "ftvsubtil/http_worker",
          "environment": %{
            "AMQP_HOSTNAME": hostname,
            "AMQP_USERNAME": username,
            "AMQP_PASSWORD": password,
            "AMQP_VHOST": virtual_host
          },
          "volumes": volumes
        }
      },
      %{
        "id": "file-system-worker",
        "label": "File System Worker",
        "params": %{
          "image": "ftvsubtil/file_system_worker",
          "environment": %{
            "AMQP_HOSTNAME": hostname,
            "AMQP_USERNAME": username,
            "AMQP_PASSWORD": password,
            "AMQP_VHOST": virtual_host
          },
          "volumes": volumes
        }
      }
    ]

    conn
    |> json(%{data: images})
  end
end
