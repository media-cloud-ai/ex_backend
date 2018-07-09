defmodule ExBackend.Amqp.JobHttpEmitter do
  use ExBackend.Amqp.CommonEmitter, %{
    queue: "job_http"
  }
end
