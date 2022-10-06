defmodule ExBackendWeb.Router do
  use ExBackendWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(ExBackendWeb.Auth.TokenCookie)
  end

  get("/app", ExBackendWeb.ApplicationController, :index)
  get("/validate", ExBackendWeb.ConfirmController, :index)

  scope "/api", ExBackendWeb do
    pipe_through(:api)

    post("/sessions", SessionController, :create)
    resources("/users", UserController, except: [:new, :edit])
    get("/users/filters/workflow", UserController, :get_workflow_filters)
    post("/users/filters/workflow", UserController, :save_workflow_filters)
    delete("/users/filters/workflow/:filter_id", UserController, :delete_workflow_filters)
    get("/users/search/:uuid", UserController, :get_by_uuid)
    post("/users/generate_credentials", UserController, :generate_credentials)
    post("/users/generate_validation_link", UserController, :generate_validation_link)
    delete("/users/roles/:name", UserController, :delete_role)
    post("/users/check_rights", UserController, :check_rights)
    resources("/watchers", WatcherController, except: [:new, :edit])

    post("/password_resets", PasswordResetController, :create)
    put("/password_resets/update", PasswordResetController, :update)

    scope "/step_flow", StepFlow do
      forward("/", Plug)
    end

    scope "/amqp", Amqp do
      get("/queues", AmqpController, :queues)
      get("/connections", AmqpController, :connections)
    end

    resources("/persons", PersonController, except: [:new, :edit])

    get("/imdb/search/:query", ImdbController, :index)
    get("/imdb/:id", ImdbController, :show)

    resources("/credentials", CredentialController, except: [:new, :edit])
    get("/credentials/search/:key", CredentialController, :get_by_key)

    get("/documentation", DocumentationController, :index)

    get("/s3_config", S3Controller, :config)
    get("/s3_signer", S3Controller, :signer)
    get("/s3_presign_url", S3Controller, :presign_url)
  end

  get("/stream/:content/manifest.mpd", ExBackendWeb.PlayerController, :manifest)
  get("/stream/:content/:filename", ExBackendWeb.PlayerController, :index)
  options("/stream/:content/:filename", ExBackendWeb.PlayerController, :options)

  scope "/swagger" do
    forward("/backend", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :ex_backend,
      swagger_file: "backend_swagger.json"
    )

    forward("/step_flow", ExBackendWeb.StepFlowSwagger,
      otp_app: :ex_backend,
      swagger_file: "step_flow_swagger.json"
    )
  end

  scope "/", ExBackendWeb do
    pipe_through(:browser)

    get("/*path", PageController, :index)
  end

  def swagger_info do
    %{
      info: %{
        version: Mix.Project.config()[:version],
        title: "Backend API documentation"
      }
    }
  end
end
