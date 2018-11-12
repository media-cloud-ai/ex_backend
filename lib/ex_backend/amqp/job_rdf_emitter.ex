defmodule ExBackend.Amqp.JobRdfEmitter do
  use ExBackend.Amqp.CommonEmitter, %{
    queue: "job_rdf"
  }
end
