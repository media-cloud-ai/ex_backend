defmodule ExBackend.Amqp.JobFtpCompletedConsumer do
  require Logger

  use ExBackend.Amqp.CommonConsumer, %{
    queue: "job_ftp_completed",
    consumer: &ExBackend.Amqp.JobFtpCompletedConsumer.consume/4
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id, "status" => status} = _payload) do
    ExBackend.Jobs.Status.set_job_status(job_id, status)

    ExBackend.WorkflowStepManager.check_step_status(%{job_id: job_id})
    Basic.ack(channel, tag)
  end
end
