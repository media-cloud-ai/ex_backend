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
          type: :object,
          additionalProperties: %Schema{
            type: :string
          },
          description: "Indicated whether specified action is authorized or not on given entity"
        }
      },
      example: %{
        "authorized" => %{
          "create" => true,
          "delete" => false
        }
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
        action: %Schema{type: :array, description: "Actions to check"}
      },
      example: %{
        "entity" => "workflow::*",
        "actions" => ["view", "create"]
      }
    })
  end
end
