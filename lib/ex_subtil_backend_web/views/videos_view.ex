defmodule ExSubtilBackendWeb.VideosView do
  use ExSubtilBackendWeb, :view
  alias ExSubtilBackendWeb.VideosView

  def render("index.json", %{videos: videos}) do
    %{
      size: videos.size,
      total: videos.total,
      data: render_many(videos.videos, VideosView, "video.json")
    }
  end

  def render("video.json", %{videos: video}) do
    %{
      id: video["id"],
      title: video["title"]
    }
  end

end
