defmodule ExSubtilBackendWeb.VideosView do
  use ExSubtilBackendWeb, :view
  alias ExSubtilBackendWeb.VideosView

  def render("index.json", %{videos: videos}) do
    %{data: render_many(videos, VideosView, "video.json")}
  end

  def render("video.json", %{videos: video}) do
    %{
      id: video["id"],
      title: video["title"]
    }
  end

end
