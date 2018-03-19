defmodule ExSubtilBackend.Amqp.JobFileSystemEmitter do
  use ExSubtilBackend.Amqp.CommonEmitter, %{
    queue: "job_clean"
  }
end
