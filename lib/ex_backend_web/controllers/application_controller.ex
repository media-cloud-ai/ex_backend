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
    description: "Gives MCAI Backend application informations",
    type: :object,
    responses: [
      ok: {"Application", "application/json", OpenApiSchemas.Application.Application},
      forbidden: "Forbidden"
    ]

  def index(conn, _params) do
    identifier =
      System.get_env("APP_IDENTIFIER") || Application.get_env(:ex_backend, :app_identifier)

    label = System.get_env("APP_LABEL") || Application.get_env(:ex_backend, :app_label)
    company = System.get_env("APP_COMPANY") || Application.get_env(:ex_backend, :app_company)

    company_logo =
      System.get_env("APP_COMPANY_LOGO") || Application.get_env(:ex_backend, :app_company_logo)

    logo = System.get_env("APP_LOGO") || Application.get_env(:ex_backend, :app_logo)

    {:ok, version} = :application.get_key(:ex_backend, :vsn)

    json(conn, %{
      identifier: identifier,
      label: label,
      company: company,
      company_logo: "/bundles/images/" <> company_logo,
      logo: "/bundles/images/" <> logo,
      version: version |> List.to_string()
    })
  end
end
