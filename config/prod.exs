import Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# ExBackendWeb.Endpoint.init/2 when load_from_system_env is
# true. Any dynamic configuration should be done there.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phx.digest task
# which you typically run after static files are built.
config :ex_backend, ExBackendWeb.Endpoint,
  load_from_system_env: true,
  https: [host: {:system, "EXPOSED_DOMAIN_NAME"}, port: 443],
  check_origin: false,
  root: ".",
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :ex_backend, ExBackendWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :ex_backend, ExBackendWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :ex_backend, ExBackendWeb.Endpoint, server: true
#

config :ex_backend, ExBackendWeb.Endpoint,
  secret_key_base: {:system, "MCAI_BACKEND_SECRET_KEY_BASE"}

config :logger, level: :info

config :httpotion, :default_timeout, 60000

# Configure your database
config :ex_backend, ExBackend.Repo,
  migration_timestamps: [type: :naive_datetime_usec],
  username: {:system, "DATABASE_USERNAME"},
  password: {:system, "DATABASE_PASSWORD"},
  database: {:system, "DATABASE_NAME"},
  hostname: {:system, "DATABASE_HOSTNAME"},
  port: {:system, "DATABASE_PORT"},
  runtime_pool_size: {:system, "DATABASE_POOL_SIZE"}

config :step_flow, StepFlow.Repo,
  migration_timestamps: [type: :naive_datetime_usec],
  username: {:system, "DATABASE_USERNAME"},
  password: {:system, "DATABASE_PASSWORD"},
  database: {:system, "DATABASE_NAME"},
  hostname: {:system, "DATABASE_HOSTNAME"},
  port: {:system, "DATABASE_PORT"},
  runtime_pool_size: {:system, "DATABASE_POOL_SIZE"}

config :ex_backend, ExBackend.SendGridMailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: {:system, "SENDGRID_API_KEY"}

config :ex_backend, ExBackend.SMTPMailer,
  adapter: Bamboo.SMTPAdapter,
  server: {:system, "SMTP_SERVER"},
  hostname: {:system, "SMTP_HOSTNAME"},
  port: {:system, "SMTP_PORT"},
  username: {:system, "SMTP_USERNAME", ""},
  password: {:system, "SMTP_PASSWORD", ""},
  auth: {:system, "SMTP_AUTH", "if_available"},
  tls: {:system, "SMTP_TLS", "if_available"},
  allowed_tls_versions: {:system, "SMTP_ALLOWED_TLS_VERSIONS", "tlsv1,tlsv1.1,tlsv1.2"},
  tls_log_level: String.to_atom(System.get_env("SMTP_TLS_LOG_LEVEL", "error")),
  tls_verify: String.to_atom(System.get_env("SMTP_TLS_VERIFY_PEER", "verify_peer")),
  tls_cacertfile: {:system, "SMTP_TLS_CA_TRUSTSTORE"},
  tls_cacerts: {:system, "SMTP_TLS_CA_CERTS"},
  tls_depth: {:system, "SMTP_TLS_DEPTH"},
  ssl: {:system, "SMTP_SSL", false},
  retries: {:system, "SMTP_RETRIES", 1},
  no_mx_lookups: {:system, "SMTP_NO_MX_LOOKUPS", false}

config :ex_backend,
  app_name: System.get_env("APP_IDENTIFIER", "MCAI BACKEND"),
  hostname: {:system, "EXPOSED_DOMAIN_NAME"},
  port: 443,
  ssl: true,
  appdir: "/opt/app",
  acs_app: "acs_launcher.sh",
  asp_app: "ASP_V3"

config :ex_video_factory,
  mode: :custom,
  endpoint: {:system, "VIDEO_FACTORY_ENDPOINT"}

config :step_flow, StepFlow,
  workers_work_directory: {:system, "WORKERS_WORK_DIRECTORY"},
  workflow_definition: {:system, "STEP_FLOW_WORKFLOW_DIRECTORY"},
  enable_metrics: {:system, "SPEP_FLOW_ENABLE_METRICS"}

config :step_flow, StepFlow.Metrics,
  scale: {:system, "STEP_FLOW_METRICS_SCALE"},
  delta: {:system, "STEP_FLOW_METRICS_DELTA"}

config :step_flow, StepFlow.Amqp,
  username: {:system, "AMQP_USERNAME"},
  password: {:system, "AMQP_PASSWORD"},
  port: {:system, "AMQP_PORT"},
  hostname: {:system, "AMQP_HOSTNAME"},
  virtual_host: {:system, "AMQP_VIRTUAL_HOST"}
