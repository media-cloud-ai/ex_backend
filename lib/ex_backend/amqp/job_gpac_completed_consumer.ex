defmodule ExBackend.Amqp.JobGpacCompletedConsumer do
  require Logger

  alias ExBackend.Jobs

  use ExBackend.Amqp.CommonConsumer, %{
    queue: "job_gpac_completed",
    consumer: &ExBackend.Amqp.JobGpacCompletedConsumer.consume/4
  }

  def consume(
        channel,
        tag,
        _redelivered,
        %{"job_id" => job_id, "status" => status, "output" => _paths} = payload
      ) do
    Logger.warn("receive #{inspect(payload)}")
    Jobs.Status.set_job_status(job_id, status)

    ExBackend.WorkflowStepManager.check_step_status(%{job_id: job_id})
    Basic.ack(channel, tag)
  end
end
