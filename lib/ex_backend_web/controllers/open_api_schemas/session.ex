defmodule ExBackendWeb.OpenApiSchemas.Sessions do
  @moduledoc false

  alias ExBackendWeb.OpenApiSchemas.Users
  alias OpenApiSpex.Schema

  defmodule Session do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Session",
      description: "A MCAI Backend API Session",
      type: :object,
      properties: %{
        access_token: %Schema{type: :string, description: "Personal access token"},
        user: Users.UserRedux.schema()
      },
      example: %{
        access_token: "SFMyNTY.xxxxxxxxxxx",
        user: %{
          email: "test@media-cloud.ai",
          first_name: "Test",
          id: 1,
          last_name: "Test",
          roles: [
            "editor",
            "manager",
            "technician"
          ],
          username: "Test"
        }
      }
    })
  end

  defmodule SessionBody do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "SessionBody",
      description: "Information for identification",
      type: :object,
      properties: %{
        session: %Schema{
          type: :object,
          properties: %{
            email: %Schema{type: :string, description: "User email"},
            password: %Schema{type: :string, description: "User password"}
          }
          # or:
          # %{
          #   access_key_id: %Schema{type: :string, description: "User access key"},
          #   secret_access_key: %Schema{type: :string, description: "User secret key"}
          # }
        }
      },
      example: %{
        user: %{
          email: "test@media-cloud.ai",
          password: "xxxxxxxx"
        }
      }
    })
  end
end
