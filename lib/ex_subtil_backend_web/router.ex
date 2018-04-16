defmodule ExSubtilBackendWeb.Router do
  use ExSubtilBackendWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Phauxth.Authenticate, method: :token
  end

  scope "/api", ExSubtilBackendWeb do
    pipe_through :api

    post "/sessions", SessionController, :create
    resources "/users", UserController, except: [:new, :edit]
    get "/confirm", ConfirmController, :index
    post "/password_resets", PasswordResetController, :create
    put "/password_resets/update", PasswordResetController, :update

    get("/jobs", JobController, :index)
    resources("/workflows", WorkflowController, except: [:new, :edit])

    scope "/docker", Docker do
      get("/nodes", NodesController, :index)
      get("/images", ImagesController, :index)

      resources "/containers", ContainersController, except: [:new, :edit] do
        post("/start", ContainersController, :start)
        post("/stop", ContainersController, :stop)
      end
    end

    resources "/videos", VideosController, except: [:new, :edit] do
      post("/jobs", JobController, :create)
      get("/rdf", RdfController, :show)
      post("/rdf", RdfController, :create)
    end

    scope "/amqp", Amqp do
      get("/queues", AmqpController, :queues)
      get("/connections", AmqpController, :connections)
    end
  end

  scope "/", ExSubtilBackendWeb do
    pipe_through(:browser)

    get("/*path", PageController, :index)
  end
end
