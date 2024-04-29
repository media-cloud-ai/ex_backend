import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_backend, ExBackendWeb.Endpoint,
  http: [port: 4001],
  server: false

# Configure your database
config :ex_backend, ExBackend.Repo,
  migration_timestamps: [type: :naive_datetime_usec],
  username: "postgres",
  password: "postgres",
  database: "ex_backend_test",
  hostname: "postgres",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox

config :step_flow, StepFlow.Repo,
  hostname: "postgres",
  username: "postgres",
  password: "postgres",
  database: "ex_backend_workflow_test",
  port: 5432,
  migration_source: "step_flow_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :step_flow, StepFlow, workers_work_directory: "/data"

config :ex_backend,
  app_name: System.get_env("APP_IDENTIFIER", "MCAI BACKEND"),
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
  ],
  root_dash_content: "/tmp/",
  acs_app: "./SynchroSubtilTSP_V0.6",
  akamai_video_prefix: "/test/",
  asp_app: "ASP_V3"

config :step_flow, StepFlow.Amqp,
  hostname: "rabbitmq",
  port: 5672,
  username: "guest",
  password: "guest",
  virtual_host: "",
  delivery_mode: {:system, "AMQP_DELIVERY_MODE"}

# Comeonin password hashing test config
# config :argon2_elixir,
# t_cost: 2,
# m_cost: 8
config :bcrypt_elixir, log_rounds: 4
# config :pbkdf2_elixir, rounds: 1

# Mailer test configuration
config :ex_backend, ExBackend.SMTPMailer, adapter: Bamboo.TestAdapter

# Finally import the config/test.secret.exs
if File.exists?("config/test.secret.exs"),
  do: import_config("test.secret.exs")
