use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :ex_backend, ExBackendWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--watch",
      "--watch-poll",
      "--mode=development",
      "--stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# command from your terminal:
#
#     openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -keyout priv/server.key -out priv/server.pem
#
# The `http:` config above can be replaced with:
#
#     https: [port: 4000, keyfile: "priv/server.key", certfile: "priv/server.pem"],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :ex_backend, ExBackendWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/ex_backend_web/views/.*(ex)$},
      ~r{lib/ex_backend_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
config :logger, level: :debug
# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :ex_backend, ExBackend.Repo,
  username: "postgres",
  password: "postgres",
  database: "ex_backend_dev",
  hostname: "localhost",
  migration_source: "backend_migrations_dev",
  pool_size: 10

config :step_flow, StepFlow.Repo,
  hostname: "localhost",
  username: "postgres",
  password: "postgres",
  database: "ex_backend_workflow_dev",
  migration_source: "step_flow_migrations_dev",
  pool_size: 10

config :step_flow, StepFlow,
  workflow_definition: {:system, "STEP_FLOW_WORKFLOW_DIRECTORY"}

config :ex_backend, ExBackend.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: {:system, "SENDGRID_API_KEY"}

config :ex_backend,
  # app_identifier: "vidtext",
  # app_label: "VidText",
  # app_logo: "logo_vidtext.png",
  # app_company: "EBU T&I",
  # app_company_logo: "logo_ebu.png",
  app_identifier: "subtil",
  app_label: "DaIA",
  app_logo: "DaIA_logo.png",
  app_company: "FranceTélévisions",
  app_company_logo: "logo_id_2018_fushia13_2lignes.png",
  hostname: "localhost",
  port: 4000,
  ssl: false,
  work_dir: "/data",
  rdf_converter: [
    hostname: "localhost",
    port: 1501
  ],
  appdir: "/opt/app",
  acs_app: "acs_launcher.sh",
  asp_app: "ASP_V3",
  root_email: "admin@media-io.com",
  root_password: "admin123",
  root_dash_content: "/Users/marco/dash",
  mounted_appdir: "/Users/marco/app",
  mounted_workdir: "/Users/marco/data",
  docker_container_backend_hostname: "http://127.0.0.1:4000/api",
  docker_container_backend_username: "admin@media-io.com",
  docker_container_backend_password: "admin123",
  docker_container_amqp_tls: "false",
  docker_container_amqp_hostname: "127.0.0.1",
  docker_container_amqp_username: "mediacloudai",
  docker_container_amqp_password: "mediacloudai"

config :amqp,
  hostname: "127.0.0.1",
  port: "5672",
  username: "guest",
  password: "guest"

config :httpotion, :default_timeout, 60000

config :ex_video_factory,
  mode: :custom,
  # endpoint: "http://127.0.0.1:4001/api/"
  endpoint: "https://gatewayvf.webservices.francetelevisions.fr/v1/"

# Finally import the config/prod.secret.exs
# with the private section for passwords
import_config "dev.secret.exs"
