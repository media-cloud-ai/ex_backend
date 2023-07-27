defmodule ExBackend.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_backend,
      version: "1.7.3",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      compilers: [:phoenix] ++ Mix.compilers(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases()
    ]
  end

  def blue_bird_info do
    [
      host: "https://backend.media-io.com",
      title: "Media-IO Backend",
      description: "REST API documentation for the Media-IO backend",
      contact: [
        name: "Media-IO",
        url: "https://media-io.com",
        email: "contact@media-io.com"
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExBackend.Application, []},
      extra_applications: [
        :lager,
        :logger,
        :amqp,
        :bamboo,
        :bcrypt_elixir,
        :blue_bird,
        :ecto_sql,
        :httpoison,
        :jason,
        :libvault,
        :phauxth,
        :phoenix_ecto,
        :poison,
        :postgrex,
        :runtime_tools,
        :timex,
        :elixir_make,
        :parse_trans,
        :step_flow,
        :tesla
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:amqp, "~> 3.1.0"},
      {:bcrypt_elixir, "~> 2.0"},
      {:bamboo, "~> 2.2.0"},
      {:bamboo_smtp, "~> 4.2.1"},
      {:blue_bird, "~> 0.4.1"},
      {:comeonin, "~> 5.1"},
      {:cors_plug, "~> 2.0"},
      {:cowboy, "~> 2.9.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:distillery, "~> 2.1"},
      {:ecto, "~> 3.6.1"},
      {:ecto_sql, "~> 3.6.1"},
      {:excoveralls, "~> 0.13", only: :test},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:ex_imdb_sniffer, "~> 0.1.1"},
      {:ex_mock, "~> 0.1.1", only: :test},
      {:ex_video_factory, "0.3.14"},
      {:fake_server, "~> 2.1", only: :test},
      {:gettext, "~> 0.14"},
      {:hackney, "~> 1.6"},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.1"},
      {:lager, "3.8.0"},
      {:libvault, "~> 0.2.1"},
      {:mix_audit, "~> 1.0", only: [:dev, :test], runtime: false},
      {:open_api_spex, "~> 3.13"},
      {:phoenix, "~> 1.5.3"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 2.0"},
      {:phauxth, "~> 2.2"},
      {:plug, "~> 1.11.0"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, "~> 0.15.0"},
      {:ranch, "~> 1.8.0"},
      {:remote_dockers, "1.4.0"},
      {:sigaws, "~> 0.7.2"},
      {:step_flow, "1.7.3"},
      {:tesla, "~> 1.4.0"},
      {:timex, "~> 3.6"},
      {:uuid, "~> 1.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      audit: ["deps.audit"],
      checks: [
        "ecto.create --quiet",
        "test",
        "format --check-formatted",
        "credo --strict",
        "deps.audit"
      ],
      dev: ["ecto.drop", "ecto.setup", "phx.server -r priv/repo/seeds.exs"],
      "openapi.stepflow": [
        "openapi.spec.json --spec StepFlow.ApiSpec --start-app=false --pretty priv/static/step_flow_openapi.json"
      ],
      "openapi.backend": [
        "openapi.spec.json --spec ExBackendWeb.ApiSpec --start-app=false --pretty priv/static/backend_openapi.json"
      ],
      test: ["ecto.drop", "ecto.create --quiet", "ecto.migrate", "test"],
      version: &get_version/1
    ]
  end

  defp get_version(_) do
    project()
    |> Keyword.fetch!(:version)
    |> IO.puts()
  end
end
