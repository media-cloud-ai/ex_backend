import Config

# Runtime configuration of the endpoint.
#
# Get from the compiled configuration whether some endpoint parameters
# should be loaded from the system environment.

load_from_system_env =
  Application.get_env(:ex_backend, ExBackendWeb.Endpoint)
  |> Keyword.get(:load_from_system_env, false)

if load_from_system_env do
  port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"

  hostname =
    System.get_env("HOSTNAME") || raise "expected the HOSTNAME environment variable to be set"

  protocol = String.to_existing_atom(System.get_env("INTERNET_PROTOCOL", "inet6"))

  config :ex_backend, ExBackendWeb.Endpoint,
    http: [protocol, port: port],
    url: [host: hostname, port: port]
end
