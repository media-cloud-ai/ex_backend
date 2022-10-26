defmodule ExBackendWeb.OpenApiSchemas.Watchers do
  @moduledoc false

  alias ExBackendWeb.OpenApiSchemas.Users
  alias OpenApiSpex.Schema

  defmodule Connection do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Connection",
      description: "A MCAI Backend connection",
      type: :object,
      properties: %{
        online_at: %Schema{type: :string, description: "Date when last online"},
        identifier: %Schema{type: :string, description: "Identifier"}
      },
      example: %{
        "online_at" => "2022-10-23T13:00:36",
        "identifier" => "toto"
      }
    })
  end

  defmodule Connections do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Connections",
      description: "A collection of Connections",
      type: :array,
      items: Connection.schema(),
      example: [
        %{
          "online_at" => "2022-10-23T13:00:36",
          "identifier" => "toto"
        }
      ]
    })
  end

  defmodule Watcher do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Watcher",
      description: "A MCAI Backend user connection watcher",
      type: :object,
      properties: %{
        user: Users.UserRedux.schema(),
        connections: Connections.schema()
      },
      example: %{
        "user" => %{
          "email" => "editor@media-cloud.ai",
          "first_name" => "MCAI",
          "id" => 3,
          "last_name" => "Editor",
          "roles" => [
            "editor"
          ],
          "username" => "editor"
        },
        "connection" => [
          %{
            "online_at" => "2022-10-23T13:00:36",
            "identifier" => "toto"
          }
        ]
      }
    })
  end

  defmodule Watchers do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Watchers",
      description: "A collection of Watchers",
      type: :array,
      items: Watcher.schema(),
      example: [
        %{
          "user" => %{
            "email" => "editor@media-cloud.ai",
            "first_name" => "MCAI",
            "id" => 3,
            "last_name" => "Editor",
            "roles" => [
              "editor"
            ],
            "username" => "editor"
          },
          "connection" => [
            %{
              "online_at" => "2022-10-23T13:00:36",
              "identifier" => "toto"
            }
          ]
        }
      ]
    })
  end
end
