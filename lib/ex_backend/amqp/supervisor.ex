defmodule ExBackend.Amqp.Supervisor do
  require Logger
  use Supervisor

  def start_link do
    Logger.warn("#{__MODULE__} start_link")
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Logger.warn("#{__MODULE__} init")
    Supervisor.init([], strategy: :one_for_one)
  end

  def start_amqp_consumming_connection(module) do
    worker_specification = worker(module, [])
    Supervisor.start_child(__MODULE__, worker_specification)
  end

  def start_all_amqp_consumming_connections() do
    # start_amqp_consumming_connection(ExBackend.Amqp.JobAcsCompletedConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobAcsErrorConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobDashManifestCompletedConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobDashManifestErrorConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobFFmpegCompletedConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobFFmpegErrorConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobFileSystemCompletedConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobFileSystemErrorConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobFtpCompletedConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobFtpErrorConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobGpacCompletedConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobGpacErrorConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobHttpCompletedConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobHttpErrorConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobIsmManifestCompletedConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobIsmManifestErrorConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobRdfCompletedConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobRdfErrorConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobSpeechToTextCompletedConsumer)
    # start_amqp_consumming_connection(ExBackend.Amqp.JobSpeechToTextErrorConsumer)
  end
end
