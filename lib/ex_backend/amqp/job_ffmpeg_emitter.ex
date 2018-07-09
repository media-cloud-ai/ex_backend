defmodule ExBackend.Amqp.JobFFmpegEmitter do
  use ExBackend.Amqp.CommonEmitter, %{
    queue: "job_ffmpeg"
  }
end
