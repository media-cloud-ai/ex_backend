defmodule ExSubtilBackend.CommonConsumer do

  @doc false
  defmacro __using__(opts) do
    quote do

      use GenServer
      use AMQP

      def start_link do
        GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
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

        queue = unquote(opts).queue
        exchange = unquote(opts).exchange

        AMQP.Queue.declare(channel, queue, durable: false)
        AMQP.Exchange.fanout(channel, exchange, durable: false)
        AMQP.Queue.bind(channel, queue, exchange)

        {:ok, _consumer_tag} = AMQP.Basic.consume(channel, queue)
        {:ok, channel}
      end

      # Confirmation sent by the broker after registering this process as a consumer
      def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, channel) do
        {:noreply, channel}
      end

      # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
      def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, channel) do
        {:stop, :normal, channel}
      end

      # Confirmation sent by the broker to the consumer process after a Basic.cancel
      def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, channel) do
        {:noreply, channel}
      end

      def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, channel) do
        data =
          payload
          |> Poison.Parser.parse!

        %{"job_id" => job_id} = data
        Logger.info "#{__MODULE__}: receive message for job #{job_id}"

        spawn fn -> unquote(opts).consumer.(channel, tag, redelivered, data) end
        {:noreply, channel}
      end

      def terminate(_reason, state) do
        AMQP.Connection.close(state.connection)
      end
    end
  end
end
