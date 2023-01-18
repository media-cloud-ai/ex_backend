defmodule ExBackendWeb.OpenApiSchemas.Credentials do
  @moduledoc false

  alias OpenApiSpex.Schema

  defmodule Credential do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Credential",
      description: "A credential of MCAI Backend",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Unique identifier in database"},
        inserted_at: %Schema{type: :integer, description: "Credential insertion date"},
        key: %Schema{type: :integer, description: "Credential Key"},
        value: %Schema{type: :integer, description: "Credential Value"}
      },
      example: %{
        "id" => 1,
        "inserted_at" => "2022-09-30T15:56:35",
        "key" => "key",
        "value" => "value"
      }
    })
  end

  defmodule Credentials do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Credentials",
      description: "A collection of Credentials",
      type: :array,
      items: Credential.schema(),
      example: [
        %{
          "id" => 1,
          "inserted_at" => "2022-09-30T15:56:35",
          "key" => "key",
          "value" => "value"
        }
      ]
    })
  end

  defmodule CredentialBody do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CredentialBody",
      description: "Credential Body",
      type: :object,
      properties: %{
        key: %Schema{type: :integer, description: "Credential Key"},
        value: %Schema{type: :integer, description: "Credential Value"}
      },
      example: [
        %{
          "key" => "key",
          "value" => "value"
        }
      ]
    })
  end
end
