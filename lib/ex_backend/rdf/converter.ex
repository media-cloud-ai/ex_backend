defmodule ExBackend.Rdf.Converter do
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
      ExBackend.Workflows.list_workflows(%{video_id: video_id})
      |> Map.get(:data, [])
      |> List.first()

    manifest =
      case workflow do
        nil ->
          ""
        _ ->
          artifact =
            workflow
            |> Map.get(:artifacts, [])
            |> List.first()

          case artifact do
            nil -> ""
            _ ->
              artifact
              |> Map.get(:resources, %{})
              |> Map.get("manifest")
          end
      end

    acs_enabled =
      if workflow != nil do
        workflow
        |> Map.get(:flow, %{steps: []})
        |> Map.get(:steps, [])
        |> has_acs_step()
      else
        false
      end

    files = ExVideoFactory.get_files_for_video_id(video_id)

    information =
      ExVideoFactory.videos(params)
      |> Map.get(:videos)
      |> List.first()
      |> case do
        nil ->
          %{files: files}
        items ->
          items
          |> Map.put(:files, files)
      end

    information =
      information
      |> Map.put(:acs_enabled, acs_enabled |> to_string)

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

    config = Application.get_env(:ex_backend, :rdf_converter)

    hostname = System.get_env("RDF_CONVERTER_HOSTNAME") || Keyword.get(config, :hostname, "")

    port =
      System.get_env("RDF_CONVERTER_PORT") ||
        Keyword.get(config, :port, "")
        |> port_format

    url = "http://" <> hostname <> ":" <> port <> "/convert"

    case HTTPotion.post(url, body: information |> Poison.encode!()) do
      %HTTPotion.ErrorResponse{message: message} ->
        {:error, "unable to convert: #{message}"}
      response ->
        {:ok, response.body}
    end
  end

  defp has_acs_step([]), do: false
  defp has_acs_step([step | steps]) do
    if Map.get(step,"name") == "acs_synchronize" do
      true
    else
      has_acs_step(steps)
    end
  end
end