defmodule ExSubtilBackend.Amqp.JobHttpErrorConsumer do
  require Logger

  alias ExSubtilBackend.Jobs.Status

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_http_error",
    consumer: &ExSubtilBackend.Amqp.JobHttpErrorConsumer.consume/4
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id, "error" => description} = payload) do
    Logger.error("HTTP error #{inspect(payload)}")
    Status.set_job_status(job_id, "error", %{message: description})
    Basic.ack(channel, tag)
  end
end
