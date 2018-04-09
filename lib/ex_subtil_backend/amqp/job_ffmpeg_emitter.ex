defmodule ExSubtilBackend.Amqp.JobFFmpegEmitter do
  use ExSubtilBackend.Amqp.CommonEmitter, %{
    queue: "job_ffmpeg"
  }
end
