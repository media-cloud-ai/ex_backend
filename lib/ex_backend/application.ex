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

      # Start the AMQP connection supervisor
      supervisor(ExBackend.Amqp.Supervisor, []),

      # Start the endpoint when the application starts
      supervisor(ExBackendWeb.Endpoint, []),
      supervisor(ExBackendWeb.Presence, []),

      # Start the AMQP connection to submit messages
      worker(ExBackend.Amqp.Connection, []),

      # Start workflow manager
      worker(ExBackend.WorkflowStepManager, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExBackend.Supervisor]
    main_supervisor = Supervisor.start_link(children, opts)

    ExBackend.Migration.All.apply_migrations()
    ExBackend.Amqp.Supervisor.start_all_amqp_consumming_connections()

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
