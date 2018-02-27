
defmodule ExSubtilBackend.Amqp.JobHttpErrorConsumer do
  require Logger

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_http_error",
    consumer: &ExSubtilBackend.Amqp.JobHttpErrorConsumer.consume/4,
  }

  def consume(channel, tag, _redelivered, payload) do
    Logger.error "HTTP error #{inspect payload}"
    Basic.ack channel, tag
  end
end
