defmodule ExBackend.Amqp.JobFtpEmitter do
  use ExBackend.Amqp.CommonEmitter, %{
    queue: "job_ftp"
  }
end
