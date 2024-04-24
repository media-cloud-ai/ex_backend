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
        identifier: %Schema{type: :string, description: "Application name"},
        label: %Schema{type: :string, description: "Application label"},
        logo: %Schema{type: :string, description: "Application logo"},
        version: %Schema{type: :string, description: "Application version"}
      },
      example: %{
        "identifier" => "MCAI BACKEND",
        "label" => "Backend",
        "logo" => "/bundles/images/media-cloud-ai_black_logo.svg",
        "version" => "1.6.0"
      }
    })
  end
end
