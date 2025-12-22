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

  config :ex_backend, :pow_assent,
    providers: [
      github: [
        layout: %{
          logo: "/bundles/images/github.png",
          display_name: "GitHub"
        },
        client_id: System.get_env("CLIENT_ID_GITHUB", ""),
        client_secret: System.get_env("CLIENT_SECRET_GITHUB", ""),
        strategy: Assent.Strategy.Github,
        enabled: System.get_env("ENABLE_SSO_GITHUB", "false")
      ],
      entraid: [
        layout: %{
          logo: "/bundles/images/microsoft.svg",
          display_name: "Microsoft"
        },
        client_id: System.get_env("CLIENT_ID_ENTRAID", ""),
        client_secret: System.get_env("CLIENT_SECRET_ENTRAID", ""),
        tenant_id: System.get_env("TENANT_ID_ENTRAID", ""),
        strategy: Assent.Strategy.AzureAD,
        enabled: System.get_env("ENABLE_SSO_ENTRAID", "false")
      ]
    ]
end
