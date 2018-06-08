defmodule ExSubtilBackend.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_subtil_backend,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExSubtilBackend.Application, []},
      extra_applications: [
        :amqp,
        :bamboo,
        :bcrypt_elixir,
        :httpotion,
        :logger,
        :phauxth,
        :poison,
        :runtime_tools,
        :timex,
        :elixir_make,
        :parse_trans,
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
      {:amqp, "~> 1.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:bamboo, github: "media-io/bamboo"},
      {:cowboy, "~> 1.1.2"},
      {:distillery, "~> 1.5"},
      {:ex_imdb_sniffer, git: "https://github.com/FTV-Subtil/ex_imdb_sniffer.git", branch: "master"},
      {:ex_video_factory, "0.3.5"},
      {:gettext, "~> 0.14"},
      {:httpotion, "~> 3.1.0"},
      {:phoenix, "~> 1.3.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:phauxth, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:poison, "~> 3.1"},
      {:ranch, "~> 1.5", override: true},
      {:remote_dockers, "1.3.0"},
      {:timex, "~> 3.2"}
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
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
