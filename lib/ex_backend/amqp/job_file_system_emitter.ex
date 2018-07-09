defmodule ExBackend.Amqp.JobFileSystemEmitter do
  use ExBackend.Amqp.CommonEmitter, %{
    queue: "job_file_system"
  }
end
