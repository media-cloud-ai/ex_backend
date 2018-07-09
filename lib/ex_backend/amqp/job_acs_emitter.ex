defmodule ExBackend.Amqp.JobAcsEmitter do
  use ExBackend.Amqp.CommonEmitter, %{
    queue: "job_acs"
  }
end
