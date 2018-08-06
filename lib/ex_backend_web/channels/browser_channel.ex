defmodule ExBackendWeb.BrowserChannel do
  use Phoenix.Channel
  require Logger
  alias ExBackendWeb.Presence

  def join("browser:all", message, socket) do
    if not Enum.empty?(message) do
      send(self(), {:after_join, message})
    end
    {:ok, socket}
  end

  def join("browser:" <> _kind, _params, _socket) do
    {:error, %{reason: "unknown"}}
  end

  def handle_info({:after_join, message}, socket) do
    push socket, "presence_state", Presence.list(socket)
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:seconds)),
      message: message,
    })
    {:noreply, socket}
  end

  def handle_in("get", %{"body" => body}, socket) do
    Logger.info("websocket message #{inspect(body)}")
    {:noreply, socket}
  end

  def handle_in("response", payload, socket) do
    # Logger.info("list path #{inspect(payload)}")
    ExBackendWeb.Endpoint.broadcast!("watch:all", "pouet", payload)
    {:noreply, socket}
  end
end
