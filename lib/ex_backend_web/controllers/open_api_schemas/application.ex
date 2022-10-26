defmodule ExBackendWeb.OpenApiSchemas.Application do
  @moduledoc false

  alias OpenApiSpex.Schema

  defmodule Application do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Application",
      description: "A MCAI Backend application description",
      type: :object,
      properties: %{
        company: %Schema{type: :string, description: "Company name"},
        company_logo: %Schema{type: :string, description: "Company logo"},
        identifier: %Schema{type: :string, description: "Application name"},
        label: %Schema{type: :string, description: "Application label"},
        logo: %Schema{type: :string, description: "Application logo"},
        version: %Schema{type: :string, description: "Application version"}
      },
      example: %{
        "company" => "MyCompany",
        "company_logo" => "/bundles/images/logo_id_2018_fushia13_2lignes.png",
        "identifier" => "MCAI BACKEND",
        "label" => "Backend",
        "logo" => "/bundles/images/app_logo.png",
        "version" => "1.6.0"
      }
    })
  end
end
