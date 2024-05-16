defmodule ExBackendWeb.UserSocket do
  @moduledoc false

  use Phoenix.Socket,
    check_origin: [
      "https://backend.media-cloud.ai",
      "https://ai.media-cloud.ai",
      "//*.media-cloud.ai"
    ]

  alias ExBackendWeb.Auth.APIAuthPlug

  ## Channels
  channel("browser:*", ExBackendWeb.BrowserChannel)
  channel("notifications:*", ExBackendWeb.NotificationChannel)
  channel("watch:*", ExBackendWeb.WatchChannel)
  channel("transfer:*", ExBackendWeb.FileTransferChannel)

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  def connect(params, socket) do
    token = Map.get(params, "userToken")

    socket =
      socket
      |> assign(:token, token)

    socket =
      case Map.get(params, "identifier") do
        nil -> socket
        identifier -> assign(socket, :identifier, identifier)
      end

    case APIAuthPlug.fetch(socket, []) do
      {_, nil} ->
        :error

      {_, verified_user} ->
        {:ok, assign(socket, :user_id, verified_user.id)}
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ExBackendWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
