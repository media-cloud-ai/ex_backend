defmodule ExBackendWeb.WatcherView do
  use ExBackendWeb, :view
  alias ExBackendWeb.WatcherView

  def render("index.json", %{watchers: watchers}) do
    %{
      data: render_many(watchers, WatcherView, "watcher.json"),
      total: length(watchers)
    }
  end

  def render("show.json", %{watcher: watcher}) do
    %{data: render_one(watcher, WatcherView, "watcher.json")}
  end

  def render("watcher.json", %{watcher: watcher}) do
    %{
      user: %{
        id: watcher.user.id,
        email: watcher.user.email
      },
      connections: watcher.connections
    }
  end
end
