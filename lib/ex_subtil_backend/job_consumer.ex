defmodule ExSubtilBackend.JobConsumer do
  require Logger
  use AMQP

  use ExSubtilBackend.CommonConsumer, %{
    queue: "job_result",
    exchange: "/",
    consumer: &ExSubtilBackend.JobConsumer.consume/4,
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id} = payload) do
    status = Map.get(payload, "status")

    ExSubtilBackend.Jobs.Status.set_job_status(job_id, status)
    ExSubtilBackendWeb.Endpoint.broadcast! "notifications:all", "job_status", payload

    Basic.ack channel, tag
  end
end