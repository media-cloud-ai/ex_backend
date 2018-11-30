defmodule ExBackend.Amqp.JobRdfErrorConsumer do
  require Logger

  alias ExBackend.Jobs.Status
  alias ExBackend.Workflows

  use ExBackend.Amqp.CommonConsumer, %{
    queue: "job_rdf_error",
    consumer: &ExBackend.Amqp.JobRdfErrorConsumer.consume/4
  }
  def consume(channel, tag, _redelivered, %{"job_id" => job_id, "message" => description} = payload) do
    Logger.error("RDF error: #{inspect(payload)}")
    Status.set_job_status(job_id, "error", %{message: description})
    Workflows.notification_from_job(job_id)
    Basic.ack(channel, tag)
  end

  def consume(channel, tag, _redelivered, payload) do
    Logger.error("RDF error, payload: #{inspect(payload)}")
    Basic.ack(channel, tag)
  end
end
