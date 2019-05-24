defmodule ExBackendWeb.SubtitleView do
  use ExBackendWeb, :view
  alias ExBackendWeb.SubtitleView

  def render("index.json", %{subtitles: subtitles}) do
    %{data: render_many(subtitles, SubtitleView, "subtitle.json")}
  end

  def render("show.json", %{subtitle: subtitle}) do
    %{data: render_one(subtitle, SubtitleView, "subtitle.json")}
  end

  def render("subtitle.json", %{subtitle: subtitle}) do
    subtitle = ExBackend.Repo.preload(subtitle, [:user, :childs])

    childs =
      Enum.map(subtitle.childs, fn child ->
        child.id
      end)

    %{
      id: subtitle.id,
      language: subtitle.language,
      version: subtitle.version,
      path: subtitle.path,
      registery_id: subtitle.registery_id,
      parent_id: subtitle.parent_id,
      childs: childs,
      inserted_at: subtitle.inserted_at,
      user: %{
        id: subtitle.user.id,
        email: subtitle.user.email
      }
    }
  end
end
