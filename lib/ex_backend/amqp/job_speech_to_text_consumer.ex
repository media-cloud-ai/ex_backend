defmodule ExBackend.Amqp.JobSpeechToTextCompletedConsumer do
  require Logger

  alias ExBackend.Jobs

  use ExBackend.Amqp.CommonConsumer, %{
    queue: "job_speech_to_text_completed",
    consumer: &ExBackend.Amqp.JobSpeechToTextCompletedConsumer.consume/4
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id, "status" => status} = payload) do
    Logger.warn("receive #{inspect(payload)}")
    Jobs.Status.set_job_status(job_id, status)

    ExBackend.WorkflowStepManager.check_step_status(%{job_id: job_id})
    Basic.ack(channel, tag)
  end
end
