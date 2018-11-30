defmodule ExBackend.Amqp.CommonEmitter do
  require Logger
  alias ExBackend.Amqp.Connection

  def publish(queue, message) do
    Connection.publish(queue, message)
  end

  def publish_json(queue, message) do
    publish(queue, Poison.encode!(message))
  end
end
