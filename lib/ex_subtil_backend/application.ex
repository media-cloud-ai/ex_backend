defmodule ExSubtilBackend.Application do
  use Application

  require Logger

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(ExSubtilBackend.Repo, []),
      # Start the endpoint when the application starts
      supervisor(ExSubtilBackendWeb.Endpoint, []),
      # Start your own worker by calling: ExSubtilBackend.Worker.start_link(arg1, arg2, arg3)
      # worker(ExSubtilBackend.Worker, [arg1, arg2, arg3]),
      worker(ExSubtilBackend.Amqp.JobFtpEmitter, []),
      worker(ExSubtilBackend.Amqp.JobFtpCompletedConsumer, []),
      worker(ExSubtilBackend.Amqp.JobFtpErrorConsumer, []),
      worker(ExSubtilBackend.Amqp.JobGpacEmitter, []),
      worker(ExSubtilBackend.Amqp.JobGpacCompletedConsumer, []),
      worker(ExSubtilBackend.Amqp.JobGpacErrorConsumer, []),
      worker(ExSubtilBackend.Amqp.JobHttpEmitter, []),
      worker(ExSubtilBackend.Amqp.JobHttpCompletedConsumer, []),
      worker(ExSubtilBackend.Amqp.JobHttpErrorConsumer, []),
      worker(ExSubtilBackend.Amqp.JobFileSystemEmitter, []),
      worker(ExSubtilBackend.Amqp.JobFileSystemCompletedConsumer, []),
      worker(ExSubtilBackend.Amqp.JobFileSystemErrorConsumer, []),
      worker(ExSubtilBackend.Amqp.JobFFmpegEmitter, []),
      worker(ExSubtilBackend.Amqp.JobFFmpegCompletedConsumer, []),
      worker(ExSubtilBackend.Amqp.JobFFmpegErrorConsumer, []),
      worker(ExSubtilBackend.Amqp.JobCommandLineEmitter, []),
      worker(ExSubtilBackend.Amqp.JobCommandLineCompletedConsumer, []),
      worker(ExSubtilBackend.Amqp.JobCommandLineErrorConsumer, []),
      worker(ExSubtilBackend.WorkflowStepManager, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExSubtilBackend.Supervisor]
    main_supervisor = Supervisor.start_link(children, opts)

    Ecto.Migrator.up(
      ExSubtilBackend.Repo,
      20_171_116_223_034,
      ExSubtilBackend.Migration.CreateJobs
    )

    Ecto.Migrator.up(
      ExSubtilBackend.Repo,
      20_171_121_233_956,
      ExSubtilBackend.Migration.CreateStatus
    )

    Ecto.Migrator.up(
      ExSubtilBackend.Repo,
      20_180_213_135_100,
      ExSubtilBackend.Migration.CreateWorkflow
    )

    Ecto.Migrator.up(
      ExSubtilBackend.Repo,
      20_180_213_171_900,
      ExSubtilBackend.Migration.AddLinkBetweenJobAndWorkflow
    )

    Ecto.Migrator.up(
      ExSubtilBackend.Repo,
      20_180_319_162_700,
      ExSubtilBackend.Migration.CreateArtifacts
    )

    Ecto.Migrator.up(
      ExSubtilBackend.Repo,
      20_180_416_110_632,
      ExSubtilBackend.Migration.CreateUsers
    )

    Ecto.Migrator.up(
      ExSubtilBackend.Repo,
      20_180_416_094_200,
      ExSubtilBackend.Migration.AddStatusDescription
    )

    root_email =
      System.get_env("ROOT_EMAIL") || Application.get_env(:ex_subtil_backend, :root_email)

    root_password =
      System.get_env("ROOT_PASSWORD") || Application.get_env(:ex_subtil_backend, :root_password)

    if !is_nil(root_email) && !is_nil(root_password) &&
         is_nil(ExSubtilBackend.Accounts.get_by(%{"email" => root_email})) do
      user = %{email: root_email, password: root_password}

      {:ok, user} = ExSubtilBackend.Accounts.create_user(user)
      {:ok, _user} = ExSubtilBackend.Accounts.confirm_user(user)
    else
      Logger.warn("No root user (re-)created")
    end

    main_supervisor
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExSubtilBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
