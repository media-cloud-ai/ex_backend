
defmodule ExSubtilBackend.Amqp.JobFtpErrorConsumer do
  require Logger

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_ftp_error",
    consumer: &ExSubtilBackend.Amqp.JobFtpErrorConsumer.consume/4,
  }

  def consume(channel, tag, _redelivered, payload) do
    # ExSubtilBackend.Jobs.Status.set_job_status(job_id, status)
    Logger.error "FTP error #{inspect payload}"
    Basic.ack channel, tag
  end
end
