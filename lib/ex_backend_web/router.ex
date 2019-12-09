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
    plug(Phauxth.AuthenticateToken)
  end

  get("/app", ExBackendWeb.ApplicationController, :index)
  get("/validate", ExBackendWeb.ConfirmController, :index)

  scope "/api", ExBackendWeb do
    pipe_through(:api)

    post("/sessions", SessionController, :create)
    resources("/users", UserController, except: [:new, :edit])
    resources("/watchers", WatcherController, except: [:new, :edit])

    post("/password_resets", PasswordResetController, :create)
    put("/password_resets/update", PasswordResetController, :update)

    scope "/step_flow", StepFlow do
      forward("/", Plug)
    end

    get("/workflow/:identifier", WorkflowController, :get)
    post("/workflow/:identifier", WorkflowController, :create_specific)

    scope "/docker", Docker do
      post("/test", NodeController, :test)
      resources("/nodes", NodeController, except: [:new, :edit])
      resources("/images", ImagesController, except: [:new, :edit])

      resources "/containers", ContainersController, except: [:new, :edit] do
        post("/start", ContainersController, :start)
        post("/stop", ContainersController, :stop)
      end
    end

    scope "/amqp", Amqp do
      get("/queues", AmqpController, :queues)
      get("/connections", AmqpController, :connections)
    end

    resources("/persons", PersonController, except: [:new, :edit])

    get("/imdb/search/:query", ImdbController, :index)
    get("/imdb/:id", ImdbController, :show)

    resources("/credentials", CredentialController, except: [:new, :edit])

    get("/documentation", DocumentationController, :index)

    get("/s3_config", S3Controller, :config)
    get("/s3_signer", S3Controller, :signer)
    get("/s3_presign_url", S3Controller, :presign_url)
  end

  get("/stream/:content/manifest.mpd", ExBackendWeb.PlayerController, :manifest)
  get("/stream/:content/:filename", ExBackendWeb.PlayerController, :index)
  options("/stream/:content/:filename", ExBackendWeb.PlayerController, :options)

  scope "/", ExBackendWeb do
    pipe_through(:browser)

    get("/*path", PageController, :index)
  end
end
