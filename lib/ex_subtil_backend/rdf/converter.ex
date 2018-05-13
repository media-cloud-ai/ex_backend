defmodule ExSubtilBackend.Rdf.Converter do
  @moduledoc """
  The RDF Converter context.
  """

  require Logger

  defp port_format(port) when is_integer(port) do
    Integer.to_string(port)
  end

  defp port_format(port) do
    port
  end

  def get_rdf(video_id) do
    params = %{
      "qid" => video_id
    }

    workflow =
      ExSubtilBackend.Workflows.list_workflows(%{video_id: video_id})
      |> Map.get(:data, [])
      |> List.first()

    manifest =
      case workflow do
        nil ->
          ""

        _ ->
          workflow
          |> Map.get(:artifacts, [])
          |> List.first()
          |> Map.get(:resources, %{})
          |> Map.get("manifest")
      end

    files = ExVideoFactory.get_files_for_video_id(video_id)

    information =
      ExVideoFactory.videos(params)
      |> Map.get(:videos)
      |> List.first()
      |> Map.put(:files, files)

    information =
      if manifest != "" do
        manifest =
          manifest
          |> String.replace(
            "/421959/prod/innovation/",
            "http://videos-pmd.francetv.fr/innovation/"
          )

        information
        |> Map.put(:artefacts, %{manifest: manifest})
      else
        information
      end

    config = Application.get_env(:ex_subtil_backend, :rdf_converter)

    hostname = System.get_env("RDF_CONVERTER_HOSTNAME") || Keyword.get(config, :hostname, "")

    port =
      System.get_env("RDF_CONVERTER_PORT") ||
        Keyword.get(config, :port, "")
        |> port_format

    url = "http://" <> hostname <> ":" <> port <> "/convert"

    HTTPotion.post(url, body: information |> Poison.encode!()).body
  end
end
