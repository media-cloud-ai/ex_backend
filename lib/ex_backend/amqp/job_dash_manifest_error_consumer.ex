defmodule ExBackend.Amqp.JobDashManifestErrorConsumer do
  require Logger

  alias ExBackend.Jobs.Status
  alias ExBackend.Workflows

  use ExBackend.Amqp.CommonConsumer, %{
    queue: "job_dash_manifest_error",
    consumer: &ExBackend.Amqp.JobDashManifestErrorConsumer.consume/4
  }

  def consume(
        channel,
        tag,
        _redelivered,
        %{"job_id" => job_id, "status" => "error", "message" => description} = payload
      ) do
    Logger.error("HTTP error #{inspect(payload)}")
    Status.set_job_status(job_id, "error", %{message: description})
    Workflows.notification_from_job(job_id)
    Basic.ack(channel, tag)
  end
end
