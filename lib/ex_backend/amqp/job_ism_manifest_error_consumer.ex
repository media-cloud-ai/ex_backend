defmodule ExBackend.Amqp.JobIsmManifestErrorConsumer do
  require Logger

  alias ExBackend.Jobs.Status
  alias ExBackend.Workflows

  use ExBackend.Amqp.CommonConsumer, %{
    queue: "job_ism_manifest_error",
    consumer: &ExBackend.Amqp.JobIsmManifestErrorConsumer.consume/4
  }

  def consume(
        channel,
        tag,
        _redelivered,
        %{
          "job_id" => job_id,
          "parameters" => [%{"id" => "message", "type" => "string", "value" => description}],
          "status" => "error"
        } = payload
      ) do
    Logger.error("ISM error #{inspect(payload)}")
    Status.set_job_status(job_id, "error", %{message: description})
    Workflows.notification_from_job(job_id)
    Basic.ack(channel, tag)
  end
end
