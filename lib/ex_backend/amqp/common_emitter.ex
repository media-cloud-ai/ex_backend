defmodule ExBackend.Amqp.CommonEmitter do
  @doc false
  defmacro __using__(opts) do
    quote do
      require Logger
      alias ExBackend.Amqp.Connection

      def publish(message) do
        Connection.publish(unquote(opts).queue, message)
      end

      def publish_json(message) do
        message
        |> Poison.encode!()
        |> publish
      end
    end
  end
end
