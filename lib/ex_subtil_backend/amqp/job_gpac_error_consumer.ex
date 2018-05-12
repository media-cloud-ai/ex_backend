defmodule ExSubtilBackend.Amqp.JobGpacErrorConsumer do
  require Logger

  alias ExSubtilBackend.Jobs.Status
  alias ExSubtilBackend.Workflows

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_gpac_error",
    consumer: &ExSubtilBackend.Amqp.JobGpacErrorConsumer.consume/4
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id, "error" => description} = payload) do
    Logger.error("GPAC error #{inspect(payload)}")
    Status.set_job_status(job_id, "error", %{message: description})
    Workflows.notification_from_job(job_id)
    Basic.ack(channel, tag)
  end
end
