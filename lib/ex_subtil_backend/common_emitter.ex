defmodule ExSubtilBackend.CommonEmitter do

  @doc false
  defmacro __using__(opts) do
    quote do

      use GenServer

      def start_link do
        GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
      end

      def publish(message) do
        GenServer.cast(__MODULE__, {:publish, message})
      end

      def publish_json(message) do
        message
        |> Poison.encode!
        |> publish
      end

      def port_format(port) when is_integer(port) do
        Integer.to_string(port)
      end
      def port_format(port) do
        port
      end

      def init(:ok) do
        hostname = System.get_env("AMQP_HOSTNAME") || Application.get_env(:amqp, :hostname)
        username = System.get_env("AMQP_USERNAME") || Application.get_env(:amqp, :username)
        password = System.get_env("AMQP_PASSWORD") || Application.get_env(:amqp, :password)
        virtual_host = System.get_env("AMQP_VHOST") || Application.get_env(:amqp, :virtual_host) || ""

        virtual_host =
          case virtual_host do
            "" -> virtual_host
            _ -> "/" <> virtual_host
          end

        port =
          System.get_env("AMQP_PORT") || Application.get_env(:amqp, :port) || 5672
          |> port_format

        url = "amqp://" <> username <> ":" <> password <> "@" <> hostname <> ":" <> port <> virtual_host
        {:ok, connection} = AMQP.Connection.open(url)
        {:ok, channel} = AMQP.Channel.open(connection)
        AMQP.Queue.declare(channel, unquote(opts).queue)
        {:ok, %{channel: channel, connection: connection} }
      end

      def handle_cast({:publish, message}, state) do
        AMQP.Basic.publish(state.channel, "", unquote(opts).queue, message)
        {:noreply, state}
      end

      def terminate(_reason, state) do
        AMQP.Connection.close(state.connection)
      end
    end
  end
end
