defmodule ExBackendWeb.WatcherController do
  use ExBackendWeb, :controller
  use OpenApiSpex.ControllerSpecs

  import ExBackendWeb.Authorize
  alias ExBackend.Accounts
  alias ExBackendWeb.OpenApiSchemas

  tags ["Watchers"]
  security [%{"authorization" => %OpenApiSpex.SecurityScheme{type: "http", scheme: "bearer"}}]

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :show, :update, :delete])
  plug(:right_administrator_check when action in [:update, :delete])

  operation :index,
    summary: "List user connections",
    description: "List all user connections to MCAI Backend",
    type: :object,
    responses: [
      ok: {"Watchers", "application/json", OpenApiSchemas.Watchers.Watchers},
      forbidden: "Forbidden"
    ]

  def index(conn, _params) do
    watchers =
      Phoenix.Presence.list(ExBackendWeb.Presence, "browser:all")
      |> Map.to_list()
      |> format_watchers()

    render(conn, "index.json", watchers: watchers)
  end

  def format_watchers(watchers, result \\ [])
  def format_watchers([], result), do: result

  def format_watchers([head | tail], result) do
    {user_id, %{metas: metas}} = head
    user = Accounts.get(user_id)

    connections =
      Enum.map(metas, fn connection ->
        date_time =
          connection.online_at
          |> String.to_integer()
          |> DateTime.from_unix!()

        identifier =
          case connection do
            %{message: %{"identifier" => identifier}} ->
              identifier

            _ ->
              nil
          end

        %{
          online_at: date_time,
          identifier: identifier
        }
      end)

    user_connection = %{
      user: user,
      connections: connections
    }

    result = List.insert_at(result, -1, user_connection)
    format_watchers(tail, result)
  end
end
