
defmodule ExSubtilBackend.Amqp.JobCleanEmitter do
  use ExSubtilBackend.Amqp.CommonEmitter, %{
    queue: "job_clean"
  }
end
