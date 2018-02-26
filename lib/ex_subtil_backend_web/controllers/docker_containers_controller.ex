defmodule ExSubtilBackendWeb.Docker.ContainersController do
  use ExSubtilBackendWeb, :controller

  defp get_config(params) do
    %ExRemoteDockers.HostConfig{
      host: params["host"],
      port: params["port"],
      ssl: params["ssl"]
    }
  end

  def index(conn, params) do
    response =
      get_config(params)
      |> ExRemoteDockers.Containers.list()
    render(conn, "index.json", containers: response.body)
  end

end
