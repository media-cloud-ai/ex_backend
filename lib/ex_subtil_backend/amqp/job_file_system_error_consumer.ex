
defmodule ExSubtilBackend.Amqp.JobFileSystemErrorConsumer do
  require Logger

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_file_system_error",
    consumer: &ExSubtilBackend.Amqp.JobFileSystemErrorConsumer.consume/4,
  }

  def consume(channel, tag, _redelivered, payload) do
    Logger.error "Clean error #{inspect payload}"
    Basic.ack channel, tag
  end
end
