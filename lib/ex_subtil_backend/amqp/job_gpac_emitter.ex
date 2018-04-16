defmodule ExSubtilBackend.Amqp.JobGpacEmitter do
  use ExSubtilBackend.Amqp.CommonEmitter, %{
    queue: "job_gpac"
  }
end
