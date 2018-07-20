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

    resources("/workflows", WorkflowController, except: [:new, :edit]) do
      post("/events", WorkflowEventsController, :handle)
    end

    scope "/docker", Docker do
      post("/test", NodeController, :test)
      resources("/nodes", NodeController, except: [:new, :edit])
      get("/images", ImagesController, :index)

      resources "/containers", ContainersController, except: [:new, :edit] do
        post("/start", ContainersController, :start)
        post("/stop", ContainersController, :stop)
      end
    end

    resources "/catalog", CatalogController, except: [:new, :edit] do
      post("/jobs", JobController, :create)
      get("/rdf", RdfController, :show)
      post("/rdf", RdfController, :create)
    end

    scope "/amqp", Amqp do
      get("/queues", AmqpController, :queues)
      get("/connections", AmqpController, :connections)
    end

    resources("/persons", PersonController, except: [:new, :edit])
    get("/imdb/search/:query", ImdbController, :index)
    get("/imdb/:id", ImdbController, :show)
  end

  scope "/", ExBackendWeb do
    pipe_through(:browser)

    get("/*path", PageController, :index)
  end
end