
defmodule ExSubtilBackend.Amqp.JobFtpCompletedConsumer do
  require Logger

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_ftp_completed",
    consumer: &ExSubtilBackend.Amqp.JobFtpCompletedConsumer.consume/4,
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id, "status" => status} = _payload) do
    ExSubtilBackend.Jobs.Status.set_job_status(job_id, status)

    ExSubtilBackend.WorkflowStepManager.check_step_status(%{job_id: job_id})
    Basic.ack channel, tag
  end
end
