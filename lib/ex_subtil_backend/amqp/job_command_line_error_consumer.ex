defmodule ExSubtilBackend.Amqp.JobCommandLineErrorConsumer do
  require Logger

  alias ExSubtilBackend.Jobs.Status

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_command_line_error",
    consumer: &ExSubtilBackend.Amqp.JobCommandLineErrorConsumer.consume/4,
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id} = payload) do
    Logger.error "Command line error #{inspect payload}"
    Status.set_job_status(job_id, "error")
    Basic.ack channel, tag
  end
end
