defmodule ExBackendWeb.Router do
  use ExBackendWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers, %{"content-security-policy" => "default-src 'self'"})
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(:protect_from_forgery)
    plug(ExBackendWeb.Auth.TokenCookie)
    plug(OpenApiSpex.Plug.PutApiSpec, module: ExBackendWeb.ApiSpec)
  end

  get("/app", ExBackendWeb.ApplicationController, :index)
  get("/validate", ExBackendWeb.ConfirmController, :index)

  scope "/api", ExBackendWeb do
    pipe_through(:api)

    # Session APIs
    post("/sessions", SessionController, :create)

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

    # Watchers APIs
    get("/watchers", WatcherController, :index)

    # Passwords APIs
    post("/password_resets", PasswordResetController, :create)
    put("/password_resets/update", PasswordResetController, :update)

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
  end

  # Open API JSON endpoint
  scope "/api/backend" do
    pipe_through(:api)
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

  scope "/", ExBackendWeb do
    pipe_through(:browser)

    get("/*path", PageController, :index)
  end
end
