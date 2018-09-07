defmodule ExBackend.Amqp.JobSpeechToTextEmitter do
  use ExBackend.Amqp.CommonEmitter, %{
    queue: "job_speech_to_text"
  }
end
