defmodule ExSubtilBackend.JobEmitter do
  use ExSubtilBackend.CommonEmitter, %{
    queue: "job"
  }
end
