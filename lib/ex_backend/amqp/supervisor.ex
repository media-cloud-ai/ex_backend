defmodule ExBackend.Amqp.Supervisor do
  use DynamicSupervisor
  require Logger

  def start_link(arg) do
    Logger.warn("#{__MODULE__} start_link")
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  # def start_child(supervisor, child_spec) do
  #   Logger.warn("#{__MODULE__} start_child")
  #   # If MyWorker is not using the new child specs, we need to pass a map:
  #   # spec = %{id: MyWorker, start: {MyWorker, :start_link, [foo, bar, baz]}}
  #   spec = %{supervisor: supervisor, child_spec: child_spec}
  #   DynamicSupervisor.start_child(__MODULE__, spec)
  # end

  def add_consumer(queue_name) do
    Logger.warn("#{__MODULE__} add_consumer")
    child_spec = {ExBackend.Amqp.JobFtpCompletedConsumer, {}}
    DynamicSupervisor.start_child(__MODULE__, child_spec) |> IO.inspect
  end

  @impl true
  def init(initial_arg) do
    Logger.warn("#{__MODULE__} Init")
    {:ok, conn} = rabbitmq_connect()

    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [initial_arg, :conn, conn]
    )
  end

  def port_format(port) when is_integer(port) do
    Integer.to_string(port)
  end

  def port_format(port) do
    port
  end

  defp rabbitmq_connect do
    hostname = System.get_env("AMQP_HOSTNAME") || Application.get_env(:amqp, :hostname)
    username = System.get_env("AMQP_USERNAME") || Application.get_env(:amqp, :username)
    password = System.get_env("AMQP_PASSWORD") || Application.get_env(:amqp, :password)

    virtual_host =
      System.get_env("AMQP_VHOST") || Application.get_env(:amqp, :virtual_host) || ""

    virtual_host =
      case virtual_host do
        "" -> ""
        _ -> "/" <> virtual_host
      end

    port =
      System.get_env("AMQP_PORT") || Application.get_env(:amqp, :port) ||
        5672
        |> port_format

    url =
      "amqp://" <>
        username <> ":" <> password <> "@" <> hostname <> ":" <> port <> virtual_host

    Logger.warn("#{__MODULE__}: Connecting with url: #{url}")

    case AMQP.Connection.open(url) do
      {:ok, connection} ->
        Process.monitor(connection.pid)

        {:ok, channel} = AMQP.Channel.open(connection)
        # AMQP.Queue.declare(channel, queue)
        # Logger.warn("#{__MODULE__}: connected to queue #{queue}")
        {:ok, %{channel: channel, connection: connection}}

      {:error, message} ->
        Logger.error(
          "#{__MODULE__}: unable to connect to: #{url}, reason: #{inspect(message)}"
        )

        # Reconnection loop
        :timer.sleep(10000)
        rabbitmq_connect()
    end
  end
end
