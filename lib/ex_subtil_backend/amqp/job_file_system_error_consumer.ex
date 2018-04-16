defmodule ExSubtilBackend.Amqp.JobFileSystemErrorConsumer do
  require Logger

  alias ExSubtilBackend.Jobs.Status

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_file_system_error",
    consumer: &ExSubtilBackend.Amqp.JobFileSystemErrorConsumer.consume/4
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id} = payload) do
    Logger.error("Clean error #{inspect(payload)}")
    Status.set_job_status(job_id, "error")

    Basic.ack(channel, tag)
  end
end
