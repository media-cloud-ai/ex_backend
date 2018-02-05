defmodule ExSubtilBackend.Amqp.CommonEmitter do

  @doc false
  defmacro __using__(opts) do
    quote do
      require Logger

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

      def init(:ok) do
        rabbitmq_connect()
      end

      def port_format(port) when is_integer(port) do
        Integer.to_string(port)
      end
      def port_format(port) do
        port
      end

      def handle_cast({:publish, message}, state) do
        queue = unquote(opts).queue
        Logger.warn "#{__MODULE__}: publish message on queue: #{queue}"
        AMQP.Basic.publish(state.channel, "", queue, message)
        {:noreply, state}
      end

      def handle_info({:DOWN, _, :process, _pid, _reason}, _) do
        {:ok, chan} = rabbitmq_connect()
        {:noreply, chan}
      end

      def terminate(_reason, state) do
        AMQP.Connection.close(state.connection)
      end

      defp rabbitmq_connect do
        hostname = System.get_env("AMQP_HOSTNAME") || Application.get_env(:amqp, :hostname)
        username = System.get_env("AMQP_USERNAME") || Application.get_env(:amqp, :username)
        password = System.get_env("AMQP_PASSWORD") || Application.get_env(:amqp, :password)
        virtual_host = System.get_env("AMQP_VHOST") || Application.get_env(:amqp, :virtual_host) || ""

        virtual_host =
          case virtual_host do
            "" -> "/"
            _ -> "/" <> virtual_host
          end

        port =
          System.get_env("AMQP_PORT") || Application.get_env(:amqp, :port) || 5672
          |> port_format

        url = "amqp://" <> username <> ":" <> password <> "@" <> hostname <> ":" <> port <> virtual_host
        Logger.warn "#{__MODULE__}: Connecting with url: #{url}"
        case AMQP.Connection.open(url) do
          {:ok, connection} ->
            Process.monitor(connection.pid)
            queue = unquote(opts).queue
            {:ok, channel} = AMQP.Channel.open(connection)
            AMQP.Queue.declare(channel, queue)
            Logger.warn "#{__MODULE__}: connected to queue #{queue}"
            {:ok, %{channel: channel, connection: connection} }
          {:error, message} ->
            Logger.error "#{__MODULE__}: unable to connect to: #{url}, reason: #{inspect message}"
            # Reconnection loop
            :timer.sleep(10000)
            rabbitmq_connect()
        end
      end
    end
  end
end
