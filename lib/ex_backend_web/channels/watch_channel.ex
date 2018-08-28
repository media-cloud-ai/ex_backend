defmodule ExBackendWeb.WatchChannel do
  use Phoenix.Channel
  alias ExBackendWeb.Presence

  require Logger

  def join("watch:all", message, socket) do
    send(self(), {:after_join, message})
    {:ok, socket}
  end

  def join("watch:" <> _kind, _params, _socket) do
    {:error, %{reason: "unknown"}}
  end

  def handle_info({:after_join, message}, socket) do
    push(socket, "presence_state", Presence.list(socket))

    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        online_at: inspect(System.system_time(:seconds)),
        message: message
      })

    {:noreply, socket}
  end

  def handle_in("get", %{"body" => body}, socket) do
    Logger.info("websocket message #{inspect(body)}")
    {:noreply, socket}
  end

  def handle_in("ls", %{"body" => %{"agent" => agent, "path" => path}}, socket) do
    Logger.info("list path #{inspect(path)}")

    ExBackendWeb.Endpoint.broadcast!("browser:all", "file_system", %{
      body: %{
        agent: agent,
        path: path
      }
    })

    {:reply, {:ok, %{paths: []}}, socket}
  end

  def terminate(_msg, _socket) do
    # ExBackendWeb.Endpoint.broadcast!("notifications:all", topic, %{})
    # IO.inspect msg
  end
end
