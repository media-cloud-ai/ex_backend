defmodule ExBackendWeb.OpenApiSchemas.Passwords do
  @moduledoc false

  alias OpenApiSpex.Schema

  defmodule PasswordResetBody do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "PasswordResetBody",
      description: "Password Reset Body",
      type: :object,
      properties: %{
        password_reset: %Schema{
          type: :object,
          properties: %{email: %Schema{type: :string, description: "User email"}}
        }
      },
      example: %{
        "password_reset" => %{
          "email" => "test@media-cloud.ai"
        }
      }
    })
  end

  defmodule PasswordUpdateBody do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "PasswordResetBody",
      description: "Password Reset Body",
      type: :object,
      properties: %{
        password_reset: %Schema{
          type: :object,
          properties: %{password: %Schema{type: :string, description: "Users new password"}}
        }
      },
      example: %{
        "password_reset" => %{
          "password" => "xxxxxxxxx"
        }
      }
    })
  end
end
