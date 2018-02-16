
defmodule ExSubtilBackend.Amqp.JobGpacErrorConsumer do
  require Logger

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_gpac_error",
    consumer: &ExSubtilBackend.Amqp.JobGpacErrorConsumer.consume/4,
  }

  def consume(channel, tag, _redelivered, payload) do
    # ExSubtilBackend.Jobs.Status.set_job_status(job_id, status)
    Logger.error "GPAC error #{inspect payload}"
    Basic.ack channel, tag
  end
end
