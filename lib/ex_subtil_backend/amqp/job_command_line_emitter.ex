defmodule ExSubtilBackend.Amqp.JobCommandLineEmitter do
  use ExSubtilBackend.Amqp.CommonEmitter, %{
    queue: "job_command_line"
  }
end
