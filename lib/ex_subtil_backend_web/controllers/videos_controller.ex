defmodule ExSubtilBackendWeb.VideosController do
  use ExSubtilBackendWeb, :controller

  import ExSubtilBackendWeb.Authorize

  alias ExSubtilBackend.{Videos, Workflows}

  action_fallback(ExSubtilBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index])
  plug(:right_technician_check when action in [:index])

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

    url = Videos.get_manifest_url(video_id)
    video = Map.put(video, "workflows_count", total)
    video = Map.put(video, "manifest_url", url)

    result = List.insert_at(result, -1, video)
    search_workflow(videos, result)
  end
end
