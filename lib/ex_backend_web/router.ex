defmodule ExBackendWeb.Router do
  use ExBackendWeb, :router
  use Pow.Phoenix.Router
  use PowAssent.Phoenix.Router

  # @host :ex_backend
  #       |> Application.get_env(ExBackendWeb.Endpoint)
  #       |> Keyword.fetch!(:url)
  #       |> Keyword.fetch!(:host)

  @content_security_policy (case Mix.env() do
                              :prod ->
                                # "connect-src 'self' wss://#{@host};" <>
                                "default-src 'self' 'unsafe-eval';" <>
                                  "connect-src 'self';" <>
                                  "img-src 'self' blob: data:;" <>
                                  "style-src 'self' https://fonts.googleapis.com 'unsafe-inline';" <>
                                  "font-src 'self' https://fonts.gstatic.com;"

                              _ ->
                                "default-src 'self' 'unsafe-eval' 'unsafe-inline';" <>
                                  "connect-src *;" <>
                                  "img-src 'self' blob: data:;" <>
                                  "font-src http:;" <>
                                  "style-src 'unsafe-inline' https:;"
                            end)

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    # Should be added but breaks pipeline
    # Find a workaround : https://nts.strzibny.name/phoenix-csrf-protection-in-html-forms-react-forms-and-apis/
    # plug(:protect_from_forgery)
    plug(:put_secure_browser_headers, %{
      "content-security-policy" => @content_security_policy
    })

    plug(Pow.Plug.Session,
      otp_app: :ex_backend,
      session_ttl_renewal: :timer.minutes(1),
      credentials_cache_store: {Pow.Store.CredentialsCache, ttl: :timer.minutes(1)}
    )

    plug(PowAssent.Plug.Reauthorization,
      handler: PowAssent.Phoenix.ReauthorizationPlugHandler
    )

    plug(:pow_assent_persistent_session)
  end

  defp pow_assent_persistent_session(conn, _opts) do
    PowAssent.Plug.put_create_session_callback(conn, fn conn, _provider, _config ->
      PowPersistentSession.Plug.create(conn, Pow.Plug.current_user(conn))
    end)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(ExBackendWeb.Auth.APIAuthPlug, otp_app: :ex_backend)
  end

  pipeline :protected_api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    # Should be added but breaks pipeline
    # Find a workaround : https://nts.strzibny.name/phoenix-csrf-protection-in-html-forms-react-forms-and-apis/
    # plug(:protect_from_forgery)
    plug(ExBackendWeb.Auth.APIRequireAuthenticatedPlug,
      error_handler: ExBackendWeb.Auth.APIAuthErrorHandler
    )

    plug(OpenApiSpex.Plug.PutApiSpec, module: ExBackendWeb.ApiSpec)
  end

  pipeline :protected do
    plug(Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
    )
  end

  pipeline :skip_csrf_protection do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
  end

  get("/app", ExBackendWeb.ApplicationController, :index)
  get("/validate", ExBackendWeb.ConfirmController, :index)

  scope "/api", ExBackendWeb do
    pipe_through(:api)

    # Session APIs
    resources("/sessions", SessionController, singleton: true, only: [:create, :delete])
    get("/sessions/verify", SessionController, :verify)

    # Passwords APIs
    post("/password_resets", PasswordResetController, :create)
    put("/password_resets/update", PasswordResetController, :update)
  end

  scope "/api", ExBackendWeb do
    pipe_through(:protected_api)

    # Session APIs
    post("/sessions/renew", SessionController, :renew)

    # Users APIs
    resources("/users", UserController, except: [:new, :edit])
    get("/users/filters/workflow", UserController, :get_workflow_filters)
    post("/users/filters/workflow", UserController, :save_workflow_filters)
    delete("/users/filters/workflow/:filter_id", UserController, :delete_workflow_filters)
    get("/users/search/:uuid", UserController, :get_by_uuid)
    post("/users/generate_credentials", UserController, :generate_credentials)
    post("/users/generate_validation_link", UserController, :generate_validation_link)
    delete("/users/roles/:name", UserController, :delete_role)
    post("/users/check_rights", UserController, :check_rights)
    post("/users/change_password", UserController, :change_password)

    # Watchers APIs
    get("/watchers", WatcherController, :index)

    # StepFlow APIs
    scope "/step_flow", StepFlow do
      forward("/", Plug)
    end

    # AMQP APIs
    scope "/amqp", Amqp do
      get("/queues", AmqpController, :queues)
      get("/connections", AmqpController, :connections)
    end

    # Persons APIs
    resources("/persons", PersonController, except: [:new, :edit])

    #  IMDB APIs
    get("/imdb/search/:query", ImdbController, :index)
    get("/imdb/:id", ImdbController, :show)

    # Credentials APIs
    resources("/credentials", CredentialController, except: [:new, :edit])

    # S3 APIs
    get("/s3_config", S3Controller, :config)
    get("/s3_signer", S3Controller, :signer)
    get("/s3_presign_url", S3Controller, :presign_url)

    # Workflows page APIs
    get("/workflows_page", WorkflowsPageController, :index)
  end

  # Open API JSON endpoint
  scope "/api/backend" do
    pipe_through(:protected_api)
    get("/openapi", OpenApiSpex.Plug.RenderSpec, [])
  end

  # Streams endpoints
  get("/stream/:content/manifest.mpd", ExBackendWeb.PlayerController, :manifest)
  get("/stream/:content/:filename", ExBackendWeb.PlayerController, :index)
  options("/stream/:content/:filename", ExBackendWeb.PlayerController, :options)

  # Swagger UI
  scope "/swagger" do
    forward("/backend", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi")

    forward("/step_flow", ExBackendWeb.StepFlowSwaggerUI, path: "/api/step_flow/openapi")
  end

  scope "/" do
    pipe_through(:skip_csrf_protection)

    pow_assent_authorization_post_callback_routes()
  end

  scope "/" do
    pipe_through(:browser)

    pow_routes()
    pow_assent_routes()
  end

  scope "/", ExBackendWeb do
    pipe_through(:browser)

    get("/*path", PageController, :index)
  end
end
