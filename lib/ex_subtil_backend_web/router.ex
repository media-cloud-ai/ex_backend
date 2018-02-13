defmodule ExSubtilBackendWeb.Router do
  use ExSubtilBackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api", ExSubtilBackendWeb do
    pipe_through :api

    get "/test", TextController, :index
    get "/jobs", JobController, :index
    resources "/workflows", WorkflowController, except: [:new, :edit]

    resources "/videos", VideosController, except: [:new, :edit] do
      post "/jobs", JobController, :create
    end
  end

  scope "/", ExSubtilBackendWeb do
    pipe_through :browser

    get "/*path", PageController, :index
  end
end
