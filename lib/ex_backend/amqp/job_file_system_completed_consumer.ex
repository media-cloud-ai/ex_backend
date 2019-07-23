defmodule ExBackend.Amqp.JobFileSystemCompletedConsumer do
  require Logger

  alias ExBackend.Jobs

  use ExBackend.Amqp.CommonConsumer, %{
    queue: "job_file_system_completed",
    consumer: &ExBackend.Amqp.JobFileSystemCompletedConsumer.consume/4
  }

  def consume(
        channel,
        tag,
        _redelivered,
        %{"job_id" => job_id, "status" => status, "files" => _files} = payload
      ) do
    Logger.warn("receive #{inspect(payload)}")
    Jobs.Status.set_job_status(job_id, status)

    ExBackend.WorkflowStepManager.check_step_status(%{job_id: job_id})
    Basic.ack(channel, tag)
  end

  def consume(
        channel,
        tag,
        redelivered,
        payload
      ) do
    payload = Map.put(payload, "files", [])
    consume(channel, tag, redelivered, payload)
  end
end
