import Config

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
      "--watch-options-stdin",
      "--mode=development",
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
  hostname: "postgres",
  username: "postgres",
  password: "postgres",
  database: "ex_backend_dev",
  migration_source: "backend_migrations_dev",
  runtime_pool_size: 10

config :step_flow, StepFlow.Repo,
  hostname: "postgres",
  username: "postgres",
  password: "postgres",
  database: "ex_backend_workflow_dev",
  migration_source: "step_flow_migrations_dev",
  runtime_pool_size: 10

config :step_flow, StepFlow, workflow_definition: {:system, "STEP_FLOW_WORKFLOW_DIRECTORY"}

config :ex_backend, ExBackend.SendGridMailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: {:system, "SENDGRID_API_KEY"}

config :ex_backend, ExBackend.SMTPMailer,
  adapter: Bamboo.SMTPAdapter,
  server: {:system, "SMTP_SERVER"},
  # hostname e.g. "www.mydomain.com"
  hostname: {:system, "SMTP_HOSTNAME"},
  port: {:system, "SMTP_PORT"},
  username: {:system, "SMTP_USERNAME", ""},
  password: {:system, "SMTP_PASSWORD", ""},
  # auth can be 'if_available' or 'always'
  auth: {:system, "SMTP_AUTH", "if_available"},
  # tls can be 'if_available', 'always' or 'never'
  tls: {:system, "SMTP_TLS", "if_available"},
  # allowed_tls_versions: comma separated values (e.g. "tlsv1.1,tlsv1.2")
  allowed_tls_versions: {:system, "SMTP_ALLOWED_TLS_VERSIONS", "tlsv1,tlsv1.1,tlsv1.2"},
  # tls_log_level can be "critical", "error", "warning", "notice"
  tls_log_level: String.to_atom(System.get_env("SMTP_TLS_LOG_LEVEL", "error")),
  # tls_verify can be "verify_peer" or "verify_none"
  tls_verify: String.to_atom(System.get_env("SMTP_TLS_VERIFY_PEER", "verify_peer")),
  # tls_cacertfile is optional: path to the ca truststore
  tls_cacertfile: {:system, "SMTP_TLS_CA_TRUSTSTORE"},
  # tls_cacerts is optional: DER-encoded trusted certificates
  tls_cacerts: {:system, "SMTP_TLS_CA_CERTS"},
  # tls_depth is optional, tls certificate chain depth
  tls_depth: {:system, "SMTP_TLS_DEPTH"},
  # tls_verify_fun is disabled, since we found no way to set it from environment
  # tls_verify_fun: {&:ssl_verify_hostname.verify_fun/3, check_hostname: "mydomain.com"},
  ssl: {:system, "SMTP_SSL", false},
  retries: {:system, "SMTP_RETRIES", 1},
  no_mx_lookups: {:system, "SMTP_NO_MX_LOOKUPS", false}

config :ex_backend,
  app_identifier: System.get_env("APP_IDENTIFIER", "MCAI BACKEND"),
  app_label: "DaIA",
  app_logo: "DaIA_logo.png",
  app_company: "MyCompany",
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
  root_email: "admin@media-cloud.ai",
  mcai_reset_root_password: false,
  root_dash_content: "/Users/marco/dash",
  mounted_appdir: "/Users/marco/app",
  mounted_workdir: "/Users/marco/data",
  docker_container_backend_hostname: "http://127.0.0.1:4000/api",
  docker_container_backend_username: "admin@media-cloud.ai",
  docker_container_backend_password: "admin123",
  docker_container_amqp_tls: "false",
  docker_container_amqp_hostname: "127.0.0.1",
  docker_container_amqp_username: "mediacloudai",
  docker_container_amqp_password: "mediacloudai"

config :step_flow, StepFlow.Amqp,
  hostname: "localhost",
  port: "5678",
  username: "mediacloudai",
  password: "mediacloudai",
  virtual_host: "media_cloud_ai_dev",
  delivery_mode: {:system, "AMQP_DELIVERY_MODE"}

config :httpotion, :default_timeout, 60000

# Finally import the config/prod.secret.exs
# with the private section for passwords
import_config "dev.secret.exs"
