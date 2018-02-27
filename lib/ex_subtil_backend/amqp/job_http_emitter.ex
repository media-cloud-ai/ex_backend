
defmodule ExSubtilBackend.Amqp.JobHttpEmitter do
  use ExSubtilBackend.Amqp.CommonEmitter, %{
    queue: "job_http"
  }
end
