defmodule ExSubtilBackendWeb.ArtifactView do
  use ExSubtilBackendWeb, :view
  alias ExSubtilBackendWeb.ArtifactView

  def render("index.json", %{artifact: artifact}) do
    %{data: render_many(artifact, ArtifactView, "artifact.json")}
  end

  def render("show.json", %{artifact: artifact}) do
    %{data: render_one(artifact, ArtifactView, "artifact.json")}
  end

  def render("artifact.json", %{artifact: artifact}) do
    %{
      id: artifact.id,
      resources: artifact.resources,
      inserted_at: artifact.inserted_at
    }
  end
end
