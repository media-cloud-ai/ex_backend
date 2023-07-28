defmodule ExBackendWeb.NotificationChannel do
  @moduledoc false

  use Phoenix.Channel
  require Logger

  def join("notifications:all", _message, socket) do
    {:ok, socket}
  end

  def join("notifications:" <> _kind, _params, _socket) do
    {:error, %{reason: "unknown"}}
  end

  def handle_in("get", %{"body" => body}, socket) do
    Logger.debug("websocket message #{inspect(body)}")
    {:noreply, socket}
  end
end
