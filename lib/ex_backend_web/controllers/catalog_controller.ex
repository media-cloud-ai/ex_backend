defmodule ExBackendWeb.CatalogController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  alias ExBackend.{Catalog, Workflows}

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index])
  plug(:right_technician_or_ftvstudio_check when action in [:index, :show, :search_workflow])

  def index(conn, params) do
    response = ExVideoFactory.videos(params)

    videos =
      response.videos
      |> search_workflow

    response = Map.put(response, :videos, videos)

    render(conn, "index.json", videos: response)
  end

  def show(conn, params) do
    case ExVideoFactory.videos(%{"qid" => params["id"]}) do
      %{total: "1", size: 1, videos: videos} ->
        render(conn, "show.json", video: videos |> List.first())

      _ ->
        error(conn, :notfound, 404)
    end
  end

  defp search_workflow(videos, result \\ [])
  defp search_workflow([], result), do: result

  defp search_workflow([video | videos], result) do
    video_id = Map.get(video, "id")

    total =
      Workflows.list_workflows(%{video_id: video_id})
      |> Map.get(:total)

    rosetta_count =
      Workflows.list_workflows(%{video_id: video_id, identifier: "FranceTV Studio Ingest Rosetta"})
      |> Map.get(:total)

    video =
      video
      |> Map.put("workflows_count", total)
      |> Map.put("rosetta_count", rosetta_count)

    url = Catalog.get_manifest_url(video_id)
    video = Map.put(video, "workflows_count", total)
    video = Map.put(video, "manifest_url", url)

    result = List.insert_at(result, -1, video)
    search_workflow(videos, result)
  end
end
