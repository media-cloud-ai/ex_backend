defmodule ExSubtilBackendWeb.Docker.ImagesController do
  use ExSubtilBackendWeb, :controller

  def index(conn, _params) do
    images = [
      %{
        "id": "gpac-worker",
        "label": "GPAC Worker",
        "params": %{
          "Image": "ftvsubtil/gpac_worker"
        }
      },
      %{
        "id": "ftp-worker",
        "label": "FTP Worker",
        "params": %{
          "Image": "ftvsubtil/ftp_worker"
        }
      },
      %{
        "id": "http-worker",
        "label": "HTTP Worker",
        "params": %{
          "Image": "ftvsubtil/http_worker"
        }
      }
    ]

    conn
    |> json(%{data: images})
  end
end
