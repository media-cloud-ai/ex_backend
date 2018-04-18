defmodule ExSubtilBackend.Amqp.JobAcsCompletedConsumer do
  require Logger

  alias ExSubtilBackend.Jobs

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_acs_completed",
    consumer: &ExSubtilBackend.Amqp.JobAcsCompletedConsumer.consume/4
  }

  def consume(
        channel,
        tag,
        _redelivered,
        %{"job_id" => job_id, "status" => status, "output" => paths} = payload
      ) do
    Logger.warn("receive #{inspect(payload)}")
    Jobs.Status.set_job_status(job_id, status)

    job = Jobs.get_job!(job_id)

    params =
      job.params
      |> Map.put(:destination, %{paths: paths})

    Jobs.update_job(job, %{params: params})

    ExSubtilBackend.WorkflowStepManager.check_step_status(%{job_id: job_id})
    Basic.ack(channel, tag)
  end
end
