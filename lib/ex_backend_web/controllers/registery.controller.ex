defmodule ExBackendWeb.RegisteryController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  alias ExBackend.Registeries

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :show, :add_subtitle])
  plug(:right_editor_check when action in [:index, :show, :add_subtitle])

  def index(conn, params) do
    items = Registeries.list_registeries(params)
    render(conn, "index.json", items: items)
  end

  def show(conn, %{"id" => id}) do
    item = Registeries.get_registery!(id)
    render(conn, "show.json", item: item)
  end

  def add_subtitle(conn, %{"language" => language, "registery_id" => registery_id}) do
    item = Registeries.get_registery!(registery_id)

    filename = "/dash/" <> Integer.to_string(item.workflow_id) <> "/" <> UUID.uuid4() <> "_" <> language <> ".vtt"

    {:ok, file} = File.open filename, [:write]
    IO.binwrite file, "WEBVTT\n\n"
    File.close file

    subtitles =
      Map.get(item, :params)
      |> Map.get("subtitles")
      |> List.insert_at(-1, %{
        "language" => language,
        "paths" => [filename]
      })

    params =
      Map.get(item, :params)
      |> Map.put("subtitles", subtitles)

    {:ok, item} = Registeries.update_registery(item, %{params: params})
    render(conn, "show.json", item: item)
  end

  def delete_subtitle(conn, %{"index" => index, "registery_id" => registery_id}) do
    item = Registeries.get_registery!(registery_id)
    subtitles = List.delete_at(Map.get(item.params, "subtitles"), String.to_integer(index))
    params = Map.put(item.params, "subtitles", subtitles)

    {:ok, item} = Registeries.update_registery(item, %{params: params})

    render(conn, "show.json", item: item)
  end
end
