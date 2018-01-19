defmodule ExSubtilBackendWeb.VideosController do
  use ExSubtilBackendWeb, :controller

  action_fallback ExSubtilBackendWeb.FallbackController

  def index(conn, _params) do
    videos = ExVideoFactory.videos()
    render(conn, "index.json", videos: videos.videos)
  end

end
