
defmodule ExSubtilBackend.Amqp.JobFtpEmitter do
  use ExSubtilBackend.Amqp.CommonEmitter, %{
    queue: "job_ftp"
  }
end
