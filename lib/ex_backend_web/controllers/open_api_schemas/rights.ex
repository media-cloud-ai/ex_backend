defmodule ExBackendWeb.OpenApiSchemas.Rights do
  @moduledoc false

  alias OpenApiSpex.Schema

  defmodule Authorized do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Authorized",
      description: "Authorization response",
      type: :object,
      properties: %{
        authorized: %Schema{
          type: :bool,
          description: "If authorized to do action on given entity"
        }
      },
      example: %{
        "authorized" => true
      }
    })
  end

  defmodule CheckRightsBody do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CheckRightsBody",
      description: "Body for checking rights",
      type: :object,
      properties: %{
        entity: %Schema{type: :string, description: "Entity to check"},
        action: %Schema{type: :string, description: "Action to check"}
      },
      example: %{
        "entity" => "workflow::*",
        "action" => "view"
      }
    })
  end
end
