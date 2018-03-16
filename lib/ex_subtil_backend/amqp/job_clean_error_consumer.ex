
defmodule ExSubtilBackend.Amqp.JobCleanErrorConsumer do
  require Logger

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_clean_error",
    consumer: &ExSubtilBackend.Amqp.JobCleanErrorConsumer.consume/4,
  }

  def consume(channel, tag, _redelivered, payload) do
    Logger.error "Clean error #{inspect payload}"
    Basic.ack channel, tag
  end
end
