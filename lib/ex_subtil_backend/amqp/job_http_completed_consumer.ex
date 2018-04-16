defmodule ExSubtilBackend.Amqp.JobHttpCompletedConsumer do
  require Logger

  alias ExSubtilBackend.Jobs

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_http_completed",
    consumer: &ExSubtilBackend.Amqp.JobHttpCompletedConsumer.consume/4
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id, "status" => status} = payload) do
    Logger.warn("receive #{inspect(payload)}")
    Jobs.Status.set_job_status(job_id, status)

    ExSubtilBackend.WorkflowStepManager.check_step_status(%{job_id: job_id})
    Basic.ack(channel, tag)
  end
end
