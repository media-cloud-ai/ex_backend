# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ex_subtil_backend,
  ecto_repos: [ExSubtilBackend.Repo]

# Configures the endpoint
config :ex_subtil_backend, ExSubtilBackendWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VQyOE7QLAMr0qyhIR+4/NtEK9G8DU+mdESssX4ZO0j05mchaW1VzebD2dZ+r9xCS",
  render_errors: [view: ExSubtilBackendWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExSubtilBackend.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
