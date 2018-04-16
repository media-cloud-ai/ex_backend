use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_subtil_backend, ExSubtilBackendWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :ex_subtil_backend, ExSubtilBackend.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ex_subtil_backend_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :ex_subtil_backend,
  docker_hosts: [
    [
      hostname: "http://localhost",
      port: 2357,
      certfile: "/path/to/cert.pem",
      keyfile: "/path/to/key.pem"
    ]
  ]

config :amqp,
  hostname: "localhost",
  username: "guest",
  password: "guest"
