defmodule ExBackend.Amqp.JobGpacEmitter do
  use ExBackend.Amqp.CommonEmitter, %{
    queue: "job_gpac"
  }
end
