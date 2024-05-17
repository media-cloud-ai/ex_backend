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

    providers =
      case Application.get_env(:ex_backend, :pow_assent)[:providers] do
        nil -> %{}
        result -> result |> Map.new()
      end

    {:ok, version} = :application.get_key(:ex_backend, :vsn)

    json(conn, %{
      identifier: identifier,
      label: label,
      logo: "/bundles/images/" <> logo,
      version: version |> List.to_string(),
      providers: pow_provider_serializer(providers)
    })
  end

  defp pow_provider_serializer(providers) do
    Enum.map(Map.keys(providers), fn key ->
      Map.new(
        Enum.map(Map.keys(Map.new(providers[key])), fn entry ->
          value_to_map(providers[key][entry], entry)
        end)
      )
      |> Map.put(:id, to_string(key))
    end)
  end

  defp value_to_map(value, entry) when is_list(value), do: {entry, Map.new(value)}
  defp value_to_map(value, entry), do: {entry, value}
end
