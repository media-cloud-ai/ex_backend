defmodule ExBackend.Amqp.JobFileSystemErrorConsumer do
  require Logger

  alias ExBackend.Jobs.Status
  alias ExBackend.Workflows

  use ExBackend.Amqp.CommonConsumer, %{
    queue: "job_file_system_error",
    consumer: &ExBackend.Amqp.JobFileSystemErrorConsumer.consume/4
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id, "error" => description} = payload) do
    Logger.error("Clean error #{inspect(payload)}")
    Status.set_job_status(job_id, "error", %{message: description})
    Workflows.notification_from_job(job_id)
    Basic.ack(channel, tag)
  end

  def consume(
        channel,
        tag,
        _redelivered,
        %{"job_id" => job_id, "status" => "error", "message" => description} = payload
      ) do
    Logger.error("File system error #{inspect(payload)}")
    Status.set_job_status(job_id, "error", %{message: description})
    Workflows.notification_from_job(job_id)
    Basic.ack(channel, tag)
  end
end
