use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_backend, ExBackendWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :ex_backend, ExBackend.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ex_backend_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :ex_backend,
  app_name: "Subtil",
  hostname: "http://localhost:4000",
  port: 4000,
  ssl: false,
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

# Comeonin password hashing test config
# config :argon2_elixir,
# t_cost: 2,
# m_cost: 8
config :bcrypt_elixir, log_rounds: 4
# config :pbkdf2_elixir, rounds: 1

# Mailer test configuration
config :ex_backend, ExBackend.Mailer, adapter: Bamboo.TestAdapter
