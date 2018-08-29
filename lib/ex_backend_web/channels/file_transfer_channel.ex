defmodule ExBackendWeb.FileTransferChannel do
  use Phoenix.Channel
  require Logger

  intercept([
    "start",
  ])

  def join("transfer:upload", message, socket) do
    {:ok, socket}
  end

  def join("transfer:" <> _kind, _params, _socket) do
    {:error, %{reason: "unknown"}}
  end


  def handle_in("upload_data", _payload, socket) do
    Logger.info("upload_packet")
    {:noreply, socket}
  end


  def handle_out("start", payload, %{assigns: %{identifier: identifier}} = socket) do
    Logger.error(">- OUT message #{inspect(payload)}")

    if identifier == payload.parameters.source.agent do
      push(socket, "start", payload)
    end

    {:noreply, socket}
  end
end
