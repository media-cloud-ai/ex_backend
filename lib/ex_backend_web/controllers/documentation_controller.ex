defmodule ExBackendWeb.DocumentationController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index])

  api :GET, "/api/documentation" do
    title "Get API documentation"
    description "Retrieve all endpoint and parameters"
  end
  def index(conn, params) do
    response =
      BlueBird.Generator.run()
      |> Map.delete(:contact)
      |> Map.delete(:license)

    conn
    |> json(response)
  end
end