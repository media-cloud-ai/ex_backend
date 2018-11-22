# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ex_backend, ecto_repos: [ExBackend.Repo]

# Configures the endpoint
config :ex_backend, ExBackendWeb.Endpoint,
  url: [host: "localhost"],
  server: true,
  secret_key_base: "VQyOE7QLAMr0qyhIR+4/NtEK9G8DU+mdESssX4ZO0j05mchaW1VzebD2dZ+r9xCS",
  render_errors: [view: ExBackendWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExBackend.PubSub, adapter: Phoenix.PubSub.PG2]

# Phauxth authentication configuration
config :phauxth,
  token_salt: "KBPzeh/8",
  endpoint: ExBackendWeb.Endpoint

# Mailer configuration
config :ex_backend, ExBackend.Mailer, adapter: Bamboo.LocalAdapter

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :mime, :types, %{
  "application/wasm" => ["wasm"],
  "text/vtt" => ["webvtt"]
}

config :blue_bird,
  docs_path: "priv/static/docs",
  theme: "triple",
  router: ExBackendWeb.Router

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
