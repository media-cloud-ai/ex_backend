defmodule ExSubtilBackendWeb.VideosController do
  use ExSubtilBackendWeb, :controller

  alias ExSubtilBackend.Workflows

  action_fallback ExSubtilBackendWeb.FallbackController

  def index(conn, params) do
    response = ExVideoFactory.videos(params)

    videos =
      response.videos
      |> search_workflow

    response = Map.put(response, :videos, videos)

    render(conn, "index.json", videos: response)
  end

  defp search_workflow(videos, result \\ [])
  defp search_workflow([], result), do: result
  defp search_workflow([video | videos], result) do
    video_id = Map.get(video, "id")

    total =
      Workflows.list_workflows(%{video_id: video_id})
      |> Map.get(:total)

    video = Map.put(video, "workflows_count", total)

    result = List.insert_at(result, -1, video)
    search_workflow(videos, result)
  end
end
