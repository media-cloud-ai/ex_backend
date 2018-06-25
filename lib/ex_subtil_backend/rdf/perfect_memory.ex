defmodule ExSubtilBackend.Rdf.PerfectMemory do
  @moduledoc """
  The Perfect Memory integration context.
  """

  require Logger

  def publish_rdf(rdf_content) do
    config = Application.get_env(:ex_subtil_backend, :perfect_memory_endpoint)

    hostname = System.get_env("PM_ENDPOINT_HOSTNAME") || Keyword.get(config, :hostname, "")

    url = hostname <> "/v1/requests"

    body = %{
      client_id: System.get_env("PM_ENDPOINT_CLIENT_ID") || Keyword.get(config, :client_id, ""),
      name: "push_rdf_infos",
      inputs: %{
        infos_graph: %{
          value: rdf_content |> Base.encode64(),
          type: "binary"
        }
      }
    }
    |> IO.inspect

    headers = [
      "Cache-Control": "no-cache",
      "Content-Type": "application/json",
      "X-Api-Key": System.get_env("PM_ENDPOINT_API_KEY") || Keyword.get(config, :api_key, "")
    ]

    HTTPotion.post(url, body: body |> Poison.encode!(), headers: headers)
    |> IO.inspect
    |> Map.get(:status_code)
  end
end
