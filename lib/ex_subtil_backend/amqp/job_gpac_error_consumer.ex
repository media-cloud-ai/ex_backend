defmodule ExSubtilBackend.Amqp.JobGpacErrorConsumer do
  require Logger

  alias ExSubtilBackend.Jobs.Status

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_gpac_error",
    consumer: &ExSubtilBackend.Amqp.JobGpacErrorConsumer.consume/4
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id} = payload) do
    Logger.error("GPAC error #{inspect(payload)}")
    Status.set_job_status(job_id, "error")
    Basic.ack(channel, tag)
  end
end
