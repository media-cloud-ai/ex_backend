defmodule ExBackendWeb.CatalogController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index])
  plug(:right_technician_or_ftvstudio_check when action in [:index, :show, :search_workflow])

  def index(conn, params) do
    response = ExVideoFactory.videos(params)

    videos = response.videos

    response = Map.put(response, :videos, videos)

    render(conn, "index.json", videos: response)
  end

  def show(conn, params) do
    if String.match?(params["id"], ~r/^[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}$/) do
      case ExVideoFactory.videos(%{"qid" => params["id"]}) do
        %{total: "1", size: 1, videos: videos} ->
          render(conn, "show.json", video: videos |> List.first())

        _ ->
          error(conn, :not_found, 404)
      end
    else
      error(conn, :not_found, 404)
    end
  end
end
