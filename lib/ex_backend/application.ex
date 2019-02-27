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
      supervisor(ExBackendWeb.Presence, []),

      # Start your own worker by calling: ExBackend.Worker.start_link(arg1, arg2, arg3)
      # worker(ExBackend.Worker, [arg1, arg2, arg3]),
      worker(ExBackend.Amqp.Connection, []),
      # {DynamicSupervisor, name: ExBackend.Amqp.Supervisor, strategy: :one_for_one},

      worker(ExBackend.Amqp.JobAcsCompletedConsumer, []),
      worker(ExBackend.Amqp.JobAcsErrorConsumer, []),
      worker(ExBackend.Amqp.JobDashManifestCompletedConsumer, []),
      worker(ExBackend.Amqp.JobDashManifestErrorConsumer, []),
      worker(ExBackend.Amqp.JobFFmpegCompletedConsumer, []),
      worker(ExBackend.Amqp.JobFFmpegErrorConsumer, []),
      worker(ExBackend.Amqp.JobFileSystemCompletedConsumer, []),
      worker(ExBackend.Amqp.JobFileSystemErrorConsumer, []),
      worker(ExBackend.Amqp.JobFtpCompletedConsumer, []),
      worker(ExBackend.Amqp.JobFtpErrorConsumer, []),
      worker(ExBackend.Amqp.JobGpacCompletedConsumer, []),
      worker(ExBackend.Amqp.JobGpacErrorConsumer, []),
      worker(ExBackend.Amqp.JobHttpCompletedConsumer, []),
      worker(ExBackend.Amqp.JobHttpErrorConsumer, []),
      worker(ExBackend.Amqp.JobRdfCompletedConsumer, []),
      worker(ExBackend.Amqp.JobRdfErrorConsumer, []),
      worker(ExBackend.Amqp.JobSpeechToTextCompletedConsumer, []),
      worker(ExBackend.Amqp.JobSpeechToTextErrorConsumer, []),
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

    # Ecto.Migrator.up(
    #   ExBackend.Repo,
    #   20_180_424_161_800,
    #   ExBackend.Migration.WorkflowSteps
    # )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_514_190_000,
      ExBackend.Migration.UpdatePersons
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_713_172_000,
      ExBackend.Migration.CreateNodes
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_807_182_800,
      ExBackend.Migration.CreateWatchers
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_831_161_100,
      ExBackend.Migration.AddCacertFileOnNode
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_904_151_104,
      ExBackend.Migration.AddStepIdOnJob
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_904_151_130,
      ExBackend.Migration.UpdateStepIdOnJob
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_910_145_830,
      ExBackend.Migration.CreateRegistery
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_181_008_122_930,
      ExBackend.Migration.CreateSubtitles
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_181_008_133_834,
      ExBackend.Migration.MoveSubtitlesItems
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_181_113_152_855,
      ExBackend.Migration.CreateCredentials
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_190_226_190_800,
      ExBackend.Migration.AddFieldsOnWorkflow
    )

    root_email = System.get_env("ROOT_EMAIL") || Application.get_env(:ex_backend, :root_email)

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

    # BlueBird.start()

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
