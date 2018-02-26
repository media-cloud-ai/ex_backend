defmodule ExSubtilBackendWeb.VideosController do
  use ExSubtilBackendWeb, :controller

  action_fallback ExSubtilBackendWeb.FallbackController

  def index(conn, params) do
    videos = ExVideoFactory.videos(params)
    render(conn, "index.json", videos: videos)
  end
end
