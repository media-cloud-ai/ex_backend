defmodule ExBackend.Amqp.CommonEmitter do
  require Logger
  alias ExBackend.Amqp.Connection

  def publish(queue, message) do
    Connection.publish(queue, message)
  end

  def publish_json(queue, message) do
    message =
      message
      |> check_message_parameters
      |> Poison.encode!

    publish(queue, message)
  end

  def check_message_parameters(message) do
    parameters =
      message
      |> ExBackend.Map.get_by_key_or_atom(:parameters, [])
      |> Enum.filter(fn param ->
          ExBackend.Map.get_by_key_or_atom(param, :type) != "filter"
        end)

    ExBackend.Map.replace_by_atom(message, :parameters, parameters)
  end
end
