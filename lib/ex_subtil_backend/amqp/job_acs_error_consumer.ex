defmodule ExSubtilBackend.Amqp.JobAcsErrorConsumer do
  require Logger

  alias ExSubtilBackend.Jobs.Status

  use ExSubtilBackend.Amqp.CommonConsumer, %{
    queue: "job_acs_error",
    consumer: &ExSubtilBackend.Amqp.JobAcsErrorConsumer.consume/4
  }

  def consume(channel, tag, _redelivered, %{"job_id" => job_id, "error" => description} = payload) do
    Logger.error("Command line error #{inspect(payload)}")
    Status.set_job_status(job_id, "error", %{message: description})
    Basic.ack(channel, tag)
  end

  def consume(
        channel,
        tag,
        _redelivered,
        %{"job_id" => job_id, "error" => description, "code" => error_code} = payload
      ) do
    Logger.error("Command line error #{inspect(payload)}")

    description =
      case error_code do
        101 -> "[Error 101] Incorrect number of arguments"
        102 -> "[Error 102] The audio file does not exist"
        103 -> "[Error 103] The audio file should be in a WAV format"
        104 -> "[Error 104] The subtitle file does not exist"
        105 -> "[Error 105] The subtitle file should be in a TTML format"
        106 -> "[Error 106] The subtitle file cannot be opened"
        107 -> "[Error 107] Wrong format in TTML file"
        108 -> "[Error 108] Cannot access the ListNoWords.txt file"
        109 -> "[Error 109] In Thread - Incorrect config parameters"
        110 -> "[Error 110] In Thread - Cannot load S2T model files"
        111 -> "[Error 111] In Thread - Failed to open file"
        112 -> "[Error 112] In Thread - Failed to process file due to format mismatch"
        113 -> "[Error 113] In Thread - Input audio file should use 16 bits per sample"
        114 -> "[Error 114] In Thread - Input audio file should use PCM encoding"
        115 -> "[Error 115] In Thread - Input audio file should have a single mono channel"
        116 -> "[Error 116] In Thread - Input audio file should be sampled at 16000Hz"
        117 -> "[Error 117] Too few anchor words to synchronize"
        118 -> "[Error 118] Cannot save the synchronized subtitle file"
        _ -> description
      end

    Status.set_job_status(job_id, "error", %{code: error_code, message: description})
    Basic.ack(channel, tag)
  end
end
