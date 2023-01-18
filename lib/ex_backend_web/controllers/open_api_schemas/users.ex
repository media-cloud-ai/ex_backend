defmodule ExBackendWeb.OpenApiSchemas.Users do
  @moduledoc false

  alias OpenApiSpex.Schema

  defmodule User do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "User",
      description: "A MCAI Backend user",
      type: :object,
      properties: %{
        access_key_id: %Schema{type: :string, description: "API Access key ID"},
        confirmed_at: %Schema{type: :string, description: "User confirmation date"},
        email: %Schema{type: :string, description: "User email"},
        first_name: %Schema{type: :string, description: "User first name"},
        id: %Schema{type: :integer, description: "User ID"},
        inserted_at: %Schema{type: :string, description: "User insertion date"},
        last_name: %Schema{type: :string, description: "User last name"},
        roles: %Schema{
          type: :array,
          description: "User attached roles",
          items: %Schema{type: :string}
        },
        username: %Schema{type: :string, description: "Username"},
        uuid: %Schema{type: :string, description: "Unique identifier"}
      },
      example: %{
        "access_key_id" => "MCAIYTDAEPDJEMS0K02M",
        "confirmed_at" => "2022-09-23T21:30:15.000000Z",
        "email" => "editor@media-cloud.ai",
        "first_name" => "MCAI",
        "id" => 3,
        "inserted_at" => "2022-09-23T21:30:15",
        "last_name" => "Editor",
        "roles" => [
          "editor"
        ],
        "username" => "editor",
        "uuid" => "783e6266-f358-4afb-923c-2afd2266ded8"
      }
    })
  end

  defmodule UserRedux do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "User",
      description: "A MCAI Backend user",
      type: :object,
      properties: %{
        email: %Schema{type: :string, description: "User email"},
        first_name: %Schema{type: :string, description: "User first name"},
        id: %Schema{type: :integer, description: "User ID"},
        last_name: %Schema{type: :string, description: "User last name"},
        roles: %Schema{
          type: :array,
          description: "User attached roles",
          items: %Schema{type: :string}
        },
        username: %Schema{type: :string, description: "Username"}
      },
      example: %{
        "email" => "editor@media-cloud.ai",
        "first_name" => "MCAI",
        "id" => 3,
        "last_name" => "Editor",
        "roles" => [
          "editor"
        ],
        "username" => "editor"
      }
    })
  end

  defmodule UserFull do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "User",
      description: "A MCAI Backend user",
      type: :object,
      properties: %{
        access_key_id: %Schema{type: :string, description: "API Access key ID"},
        confirmed_at: %Schema{type: :string, description: "User confirmation date"},
        email: %Schema{type: :string, description: "User email"},
        first_name: %Schema{type: :string, description: "User first name"},
        id: %Schema{type: :integer, description: "User ID"},
        inserted_at: %Schema{type: :string, description: "User insertion date"},
        last_name: %Schema{type: :string, description: "User last name"},
        roles: %Schema{
          type: :array,
          description: "User attached roles",
          items: %Schema{type: :string}
        },
        username: %Schema{type: :string, description: "Username"},
        uuid: %Schema{type: :string, description: "Unique identifier"},
        secret_access_key: %Schema{type: :string, description: "API Secret access key"}
      },
      example: %{
        "access_key_id" => "MCAIYTDAEPDJEMS0K02M",
        "confirmed_at" => "2022-09-23T21:30:15.000000Z",
        "email" => "editor@media-cloud.ai",
        "first_name" => "MCAI",
        "id" => 3,
        "inserted_at" => "2022-09-23T21:30:15",
        "last_name" => "Editor",
        "roles" => [
          "editor"
        ],
        "username" => "editor",
        "uuid" => "783e6266-f358-4afb-923c-2afd2266ded8",
        "secret_access_key" => "xxxxxxxxxxxxx"
      }
    })
  end

  defmodule Users do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Users",
      description: "A collection of Users",
      type: :array,
      items: User.schema(),
      example: [
        %{
          "access_key_id" => "MCAIYTDAEPDJEMS0K02M",
          "confirmed_at" => "2022-09-23T21:30:15.000000Z",
          "email" => "editor@media-cloud.ai",
          "first_name" => "MCAI",
          "id" => 3,
          "inserted_at" => "2022-09-23T21:30:15",
          "last_name" => "Editor",
          "roles" => [
            "editor"
          ],
          "username" => "editor",
          "uuid" => "783e6266-f358-4afb-923c-2afd2266ded8",
          "secret_access_key" => "xxxxxxxxxxxxx"
        }
      ]
    })
  end

  defmodule ValidationLink do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ValidationLink",
      description: "Validation Link for registration validation",
      type: :object,
      properties: %{
        authorized: %Schema{type: :string, description: "Link"}
      },
      example: %{
        "validation_link" => "http://media-cloud.ai/confirm?key=SFMyNTY.xxxxxxxxxxxxxxx"
      }
    })
  end

  defmodule Emails do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Accounts emails",
      description: "Emails from accounts",
      type: :array,
      items: %Schema{type: :string},
      example: [
        "admin@media-cloud.ai",
        "technician@media-cloud.ai"
      ]
    })
  end

  defmodule DateRange do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "DatetimeRange",
      description: "Datetime Range",
      type: :object,
      properties: %{
        endDate: %Schema{type: :string, description: "End date"},
        startDate: %Schema{type: :string, description: "Start date"}
      },
      example: %{
        "endDate" => "2022-10-23T13:00:36.000Z",
        "startDate" => "2022-10-22T13:00:36.000Z"
      }
    })
  end

  defmodule Filter do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Filter",
      description: "User Filter",
      type: :object,
      properties: %{
        detailed: %Schema{type: :bool, description: "Detailed view on workflows"},
        identifiers: %Schema{
          type: :array,
          description: "Workflow identifiers",
          items: %Schema{type: :string}
        },
        mode: %Schema{type: :array, description: "Workflow modes", items: %Schema{type: :string}},
        selectedDateRange: DateRange.schema(),
        time_interval: %Schema{type: :integer, description: "Time interval"}
      },
      example: %{
        "detailed" => false,
        "identifiers" => [
          "my_workflow"
        ],
        "mode" => [
          "file",
          "live"
        ],
        "selectedDateRange" => %{
          "endDate" => "2022-10-23T13:00:36.000Z",
          "startDate" => "2022-10-22T13:00:36.000Z"
        },
        "status" => [
          "completed"
        ],
        "time_interval" => 1
      }
    })
  end

  defmodule Filters do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Filters",
      description: "User Filters",
      type: :array,
      items: %Schema{
        type: :object,
        properties: %{
          filter: Filter.schema(),
          id: %Schema{type: :integer, description: "Filter ID"},
          name: %Schema{type: :string, description: "Filter name"}
        }
      },
      example: [
        %{
          "filter" => %{
            "detailed" => false,
            "identifiers" => [
              "my_workflow"
            ],
            "mode" => [
              "file",
              "live"
            ],
            "selectedDateRange" => %{
              "endDate" => "2022-10-23T13:00:36.000Z",
              "startDate" => "2022-10-22T13:00:36.000Z"
            },
            "status" => [
              "completed"
            ],
            "time_interval" => 1
          },
          "id" => 20,
          "name" => "My filter"
        }
      ]
    })
  end

  defmodule FilterBody do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "FilterBody",
      description: "Filter Body",
      type: :array,
      items: %Schema{
        type: :object,
        properties: %{
          filters: Filter.schema(),
          filter_name: %Schema{type: :string, description: "Filter name"}
        }
      },
      example: %{
        "filters" => %{
          "detailed" => false,
          "identifiers" => [
            "my_workflow"
          ],
          "mode" => [
            "file",
            "live"
          ],
          "selectedDateRange" => %{
            "endDate" => "2022-10-23T13:00:36.000Z",
            "startDate" => "2022-10-22T13:00:36.000Z"
          },
          "status" => [
            "completed"
          ],
          "time_interval" => 1
        },
        "filter_name" => "My filter"
      }
    })
  end

  defmodule IdBody do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "IDBody",
      description: "User ID Body",
      type: :array,
      items: %Schema{
        type: :object,
        properties: %{
          id: %Schema{type: :integer, description: "User ID"}
        }
      },
      example: %{
        "id" => 2
      }
    })
  end
end
