defmodule ExBackendWeb.ApplicationController do
  use ExBackendWeb, :controller
  use OpenApiSpex.ControllerSpecs

  @moduledoc """
  This is the Application Controller module.
  """

  alias ExBackendWeb.OpenApiSchemas

  tags ["Application"]
  security [%{"authorization" => %OpenApiSpex.SecurityScheme{type: "http", scheme: "bearer"}}]

  action_fallback(ExBackendWeb.FallbackController)

  operation :index,
    summary: "Describe MCAI Backend",
    description: "Gives MCAI Backend application information",
    type: :object,
    responses: [
      ok: {"Application", "application/json", OpenApiSchemas.Application.Application},
      forbidden: "Forbidden"
    ]

  def index(conn, _params) do
    identifier =
      System.get_env("APP_IDENTIFIER") || Application.get_env(:ex_backend, :app_identifier)

    label = System.get_env("APP_LABEL") || Application.get_env(:ex_backend, :app_label)

    logo = System.get_env("APP_LOGO") || Application.get_env(:ex_backend, :app_logo)

    {:ok, version} = :application.get_key(:ex_backend, :vsn)

    json(conn, %{
      identifier: identifier,
      label: label,
      logo: "/bundles/images/" <> logo,
      version: version |> List.to_string()
    })
  end
end
