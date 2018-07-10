defmodule ExBackend.Application do
  use Application

  require Logger

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(ExBackend.Repo, []),
      # Start the endpoint when the application starts
      supervisor(ExBackendWeb.Endpoint, []),

      # Start your own worker by calling: ExBackend.Worker.start_link(arg1, arg2, arg3)
      # worker(ExBackend.Worker, [arg1, arg2, arg3]),
      worker(ExBackend.Amqp.Connection, []),
      # {DynamicSupervisor, name: ExBackend.Amqp.Supervisor, strategy: :one_for_one},

      worker(ExBackend.Amqp.JobFtpCompletedConsumer, []),
      worker(ExBackend.Amqp.JobFtpErrorConsumer, []),
      worker(ExBackend.Amqp.JobGpacCompletedConsumer, []),
      worker(ExBackend.Amqp.JobGpacErrorConsumer, []),
      worker(ExBackend.Amqp.JobHttpCompletedConsumer, []),
      worker(ExBackend.Amqp.JobHttpErrorConsumer, []),
      worker(ExBackend.Amqp.JobFileSystemCompletedConsumer, []),
      worker(ExBackend.Amqp.JobFileSystemErrorConsumer, []),
      worker(ExBackend.Amqp.JobFFmpegCompletedConsumer, []),
      worker(ExBackend.Amqp.JobFFmpegErrorConsumer, []),
      worker(ExBackend.Amqp.JobAcsCompletedConsumer, []),
      worker(ExBackend.Amqp.JobAcsErrorConsumer, []),
      worker(ExBackend.WorkflowStepManager, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExBackend.Supervisor]
    main_supervisor = Supervisor.start_link(children, opts)

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_171_116_223_034,
      ExBackend.Migration.CreateJobs
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_171_121_233_956,
      ExBackend.Migration.CreateStatus
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_213_135_100,
      ExBackend.Migration.CreateWorkflow
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_213_171_900,
      ExBackend.Migration.AddLinkBetweenJobAndWorkflow
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_319_162_700,
      ExBackend.Migration.CreateArtifacts
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_416_110_632,
      ExBackend.Migration.CreateUsers
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_416_094_200,
      ExBackend.Migration.AddStatusDescription
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_421_112_500,
      ExBackend.Migration.CreatePersons
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_421_171_300,
      ExBackend.Migration.AddUserRight
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_424_161_800,
      ExBackend.Migration.WorkflowSteps
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_514_190_000,
      ExBackend.Migration.UpdatePersons
    )

    root_email =
      System.get_env("ROOT_EMAIL") || Application.get_env(:ex_backend, :root_email)

    root_password =
      System.get_env("ROOT_PASSWORD") || Application.get_env(:ex_backend, :root_password)

    if !is_nil(root_email) && !is_nil(root_password) &&
         is_nil(ExBackend.Accounts.get_by(%{"email" => root_email})) do
      user = %{email: root_email, rights: ["administrator"]}

      {:ok, user} = ExBackend.Accounts.create_user(user)
      {:ok, user} = ExBackend.Accounts.update_password(user, %{password: root_password})
      {:ok, _user} = ExBackend.Accounts.confirm_user(user)
    else
      Logger.warn("No root user (re-)created")
    end

    # ExBackend.Amqp.Supervisor.add_consumer("ftp")
    main_supervisor
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
