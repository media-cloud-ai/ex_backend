defmodule ExSubtilBackendWeb.VideosController do
  use ExSubtilBackendWeb, :controller

  alias ExSubtilBackend.Jobs
  alias ExSubtilBackend.Amqp.JobFtpEmitter

  action_fallback ExSubtilBackendWeb.FallbackController

  def index(conn, params) do
    videos = ExVideoFactory.videos(params)
    render(conn, "index.json", videos: videos)
  end

  def update(conn, params) do
    legacy_id =
      Map.get(params, "id")
      |> String.to_integer

    ExVideoFactory.get_files_for_id_diffusion(legacy_id)
    |> get_hls_files([])
    |> start_transfer

    conn
    |> json(%{})
  end

  defp get_hls_files([], result), do: result
  defp get_hls_files([format | formats], result) do
    result =
      if format.format == "hls_v5_os" do
        result ++ format.urls
      else
        result
      end

    get_hls_files(formats, result)
  end

  defp start_transfer([]), do: nil
  defp start_transfer([file | files]) do

    hostname = System.get_env("AKAMAI_HOSTNAME") || Application.get_env(:ex_subtil_backend, :akamai_hostname)
    username = System.get_env("AKAMAI_USERNAME") || Application.get_env(:ex_subtil_backend, :akamai_username)
    password = System.get_env("AKAMAI_PASSWORD") || Application.get_env(:ex_subtil_backend, :akamai_password)

    job_params = %{
      name: "ftp_order",
      params: %{
        source: %{
          path: file,
          hostname: hostname,
          username: username,
          password: password,
        },
        destination: %{
          path: "/tmp/ftp_ftv" <> file
        }
      }
    }

    {:ok, job} = Jobs.create_job(job_params)
    params = %{
      job_id: job.id,
      parameters: job.params
    }
    JobFtpEmitter.publish_json(params)

    start_transfer(files)
  end

end
