defmodule ExSubtilBackend.Amqp.JobAcsEmitter do
  use ExSubtilBackend.Amqp.CommonEmitter, %{
    queue: "job_acs"
  }
end
