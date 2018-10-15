defmodule ExBackend.Rdf.PerfectMemory do
  @moduledoc """
  The Perfect Memory integration context.
  """

  require Logger

  def publish_rdf(rdf_content) do
    config = Application.get_env(:ex_backend, :perfect_memory_endpoint)

    if config == nil do
      {:error, "Missing Perfect Memory endpoint configuration"}
    else
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

      headers = [
        "Cache-Control": "no-cache",
        "Content-Type": "application/json",
        "X-Api-Key": System.get_env("PM_ENDPOINT_API_KEY") || Keyword.get(config, :api_key, "")
      ]

      status_code =
        HTTPotion.post(url, body: body |> Poison.encode!(), headers: headers)
        |> IO.inspect()
        |> Map.get(:status_code)

      case status_code do
        200 -> {:ok, "completed"}
        201 -> {:ok, "create"}
        _ -> {:error, "unable to publish to Perfect Memory (HTTP code:#{status_code})"}
      end
    end
  end
end
