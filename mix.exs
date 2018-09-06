defmodule ExBackend.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_backend,
      version: get_version(),
      elixir: "~> 1.6",
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
      mod: {ExBackend.Application, []},
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
        :parse_trans
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
      {:bcrypt_elixir, "~> 1.1"},
      {:bamboo, github: "media-io/bamboo"},
      {:cowboy, "~> 1.1.2"},
      {:distillery, "~> 2.0"},
      {:ex_imdb_sniffer, "~> 0.1.1"},
      {:ex_video_factory, "0.3.7"},
      {:gettext, "~> 0.14"},
      {:httpotion, "~> 3.1.0"},
      {:phoenix, "~> 1.3.3"},
      {:phoenix_ecto, "~> 3.2"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:phauxth, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:poison, "~> 3.1", override: true},
      {:ranch, "~> 1.5.0", override: true},
      {:ranch_proxy_protocol,
       git: "https://github.com/heroku/ranch_proxy_protocol", branch: "master", override: true},
      {:remote_dockers, "1.3.5"},
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

  defp get_version do
    version_from_file()
    |> handle_file_version()
    |> String.replace_leading("v", "")
  end

  defp version_from_file(file \\ "VERSION") do
    File.read(file)
  end

  defp handle_file_version({:ok, content}) do
    content
  end

  defp handle_file_version({:error, _}) do
    retrieve_version_from_git()
  end

  defp retrieve_version_from_git do
    require Logger

    Logger.debug(
      "Calling out to `git describe` for the version number. This is slow! You should think about a hook to set the VERSION file"
    )

    System.cmd("git", ~w{describe --always --tags --first-parent})
    |> elem(0)
    |> String.trim()
  end
end
