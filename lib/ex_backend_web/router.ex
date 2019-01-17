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
    plug(Phauxth.Authenticate, method: :token)
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

    get("/jobs", JobController, :index)

    get("/workflow/:identifier", WorkflowController, :get)
    post("/workflow/:identifier", WorkflowController, :create_specific)

    resources("/workflows", WorkflowController, except: [:new, :edit]) do
      post("/events", WorkflowEventsController, :handle)
    end

    scope "/docker", Docker do
      post("/test", NodeController, :test)
      resources("/nodes", NodeController, except: [:new, :edit])
      resources("/images", ImagesController, except: [:new, :edit])

      resources "/containers", ContainersController, except: [:new, :edit] do
        post("/start", ContainersController, :start)
        post("/stop", ContainersController, :stop)
      end
    end

    resources "/catalog", CatalogController, except: [:new, :edit] do
      post("/jobs", JobController, :create)
    end

    resources("/registery", RegisteryController, except: [:new, :edit]) do
      post("/subtitle", RegisteryController, :add_subtitle)
      put("/subtitle/:index", RegisteryController, :update_subtitle)
      delete("/subtitle/:index", RegisteryController, :delete_subtitle)
    end

    scope "/amqp", Amqp do
      get("/queues", AmqpController, :queues)
      get("/connections", AmqpController, :connections)
    end

    resources("/persons", PersonController, except: [:new, :edit])

    get("/imdb/search/:query", ImdbController, :index)
    get("/imdb/:id", ImdbController, :show)

    resources "/credentials", CredentialController, except: [:new, :edit]

    get "/documentation", DocumentationController, :index
  end

  get("/stream/:content/manifest.mpd", ExBackendWeb.PlayerController, :manifest)
  get("/stream/:content/:filename", ExBackendWeb.PlayerController, :index)
  options("/stream/:content/:filename", ExBackendWeb.PlayerController, :options)

  scope "/", ExBackendWeb do
    pipe_through(:browser)

    get("/*path", PageController, :index)
  end
end
