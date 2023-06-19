defmodule ExBackend.Application do
  @moduledoc false

  use Application

  require Logger

  alias ExBackend.Migration.All
  alias StepFlow.Rights.Right
  alias StepFlow.Roles

  @right_mapping %{
    "administrator" => [%Right{entity: "*", action: ["*"]}],
    "technician" => [
      %Right{
        entity: "workflow::*",
        action: ["abort", "create", "retry", "stop", "update", "view"]
      },
      %Right{entity: "workers::*", action: ["view"]}
    ],
    "manager" => [
      %Right{entity: "*", action: ["view"]},
      %Right{entity: "workers::*", action: ["view"]}
    ],
    "editor" => [
      %Right{entity: "workflow::*", action: ["create", "delete", "view"]},
      %Right{entity: "workers::*", action: ["view"]}
    ]
  }

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    log_level =
      System.get_env("LOG_LEVEL", "info")
      |> String.to_atom()

    Logger.configure(level: log_level)

    # Define workers and child supervisors to be supervised
    children = [
      {Phoenix.PubSub, [name: ExBackend.PubSub, adapter: Phoenix.PubSub.PG2]},
      # Start the Ecto repository
      ExBackend.Repo,

      # Start the endpoint when the application starts
      ExBackendWeb.Endpoint,
      ExBackendWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExBackend.Supervisor]
    main_supervisor = Supervisor.start_link(children, opts)

    All.apply_migrations()

    @right_mapping
    |> Map.keys()
    |> create_default_roles_if_needed()

    create_root_user_if_needed()

    main_supervisor
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp create_root_user_if_needed do
    root_email = System.get_env("ROOT_EMAIL") || Application.get_env(:ex_backend, :root_email)

    if is_nil(root_email) do
      Logger.warn("No root user created")
    else
      account = ExBackend.Accounts.get(1)

      root_password_reset =
        System.get_env("MCAI_RESET_ROOT_PASSWORD") ||
          Application.get_env(:ex_backend, :mcai_reset_root_password)

      case {is_nil(account), root_password_reset} do
        {true, _} ->
          ExBackend.Accounts.create_root(root_email)

        {false, true} ->
          ExBackend.Accounts.reset_root_password(account)

        _ ->
          Logger.notice("Root user already exists")
      end
    end
  end

  defp create_default_roles_if_needed(role_names)
  defp create_default_roles_if_needed([]), do: :ok

  defp create_default_roles_if_needed([name | roles]) do
    create_role_if_needed(name)
    create_default_roles_if_needed(roles)
  end

  defp create_role_if_needed(name) do
    case {Roles.get_by(%{"name" => name}), Map.get(@right_mapping, name)} do
      {nil, nil} ->
        Logger.error("Could not create #{name} role: unknown related rights.")

      {nil, rights} ->
        role = %{
          name: name,
          rights: rights
        }

        Logger.info("Create new #{name} role.")
        {:ok, role} = Roles.create_role(role)

        role

      {role, _} ->
        Logger.notice("Role #{name} already exists: #{inspect(role)}")
    end
  end
end
