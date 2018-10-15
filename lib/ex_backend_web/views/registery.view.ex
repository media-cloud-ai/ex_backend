defmodule ExBackendWeb.RegisteryView do
  use ExBackendWeb, :view
  alias ExBackendWeb.RegisteryView
  alias ExBackendWeb.UserView
  alias ExBackend.Accounts

  def render("index.json", %{items: %{data: items, total: total}}) do
    %{
      data: render_many(items, RegisteryView, "registery.json"),
      total: total
    }
  end

  def render("show.json", %{item: item}) do
    %{data: render_one(item, RegisteryView, "registery.json")}
  end

  def render("registery.json", %{registery: item}) do
    subtitles =
      item.subtitles
      |> render_many(ExBackendWeb.SubtitleView, "subtitle.json")

    params = Map.put(item.params, "subtitles", subtitles)

    %{
      id: item.id,
      workflow_id: item.workflow_id,
      name: item.name,
      params: params,
      inserted_at: item.inserted_at,
      updated_at: item.updated_at
    }
  end
end
