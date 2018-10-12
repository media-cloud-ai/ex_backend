defmodule ExBackendWeb.RegisteryController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  alias ExBackend.Registeries
  alias ExBackend.Subtitles

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :show, :add_subtitle, :update_subtitle])
  plug(:right_editor_check when action in [:index, :show, :add_subtitle, :update_subtitle])

  def index(conn, params) do
    items = Registeries.list_registeries(params)
    render(conn, "index.json", items: items)
  end

  def show(conn, %{"id" => id}) do
    item = Registeries.get_registery!(id)
    render(conn, "show.json", item: item)
  end

  def add_subtitle(conn, %{"language" => language, "version" => version, "registery_id" => registery_id}) do
    item = Registeries.get_registery!(registery_id)

    %Plug.Conn{assigns: %{current_user: user}} = conn

    root =
      System.get_env("ROOT_DASH_CONTENT") || Application.get_env(:ex_backend, :root_dash_content)
    filename = Path.join([root, Integer.to_string(item.workflow_id), UUID.uuid4() <> "_" <> language <> ".vtt"])

    {:ok, file} = File.open filename, [:write]
    IO.binwrite file, "WEBVTT\n\n"
    File.close file

    parameters = %{
      "language" => language,
      "version" => version,
      "user_id" => user.id,
      "registery_id" => registery_id,
      "path" => filename
    }

    {:ok, _subtitle} = Subtitles.create_subtitle(parameters)
    item = Registeries.get_registery!(registery_id)

    render(conn, "show.json", item: item)
  end

  def update_subtitle(conn, %{"index" => index, "registery_id" => registery_id}) do
    item = Registeries.get_registery!(registery_id)

    %Plug.Conn{assigns: %{current_user: user}} = conn

    {:ok, content, conn} = Plug.Conn.read_body(conn)

    subtitles = item.subtitles
    subtitle = Enum.at(subtitles, String.to_integer(index))
    language = subtitle.language

    version =
      Plug.Conn.get_req_header(conn, "x-version")
      |> List.first

    root =
      System.get_env("ROOT_DASH_CONTENT") || Application.get_env(:ex_backend, :root_dash_content)

    subtitle_filename = Path.join([root, Integer.to_string(item.workflow_id), UUID.uuid4() <> "_" <> language <> ".vtt"])
    {:ok, file} = File.open subtitle_filename, [:write]
    :ok = IO.binwrite file, content
    :ok = File.close file

    parameters = %{
      "language" => language,
      "version" => version,
      "user_id" => user.id,
      "registery_id" => registery_id,
      "parent_id" => subtitle.id,
      "path" => subtitle_filename
    }

    {:ok, _subtitle} = Subtitles.create_subtitle(parameters)
    item = Registeries.get_registery!(registery_id)

    render(conn, "show.json", item: item)
  end

  def delete_subtitle(conn, %{"index" => index, "registery_id" => registery_id}) do
    item = Registeries.get_registery!(registery_id)

    subtitle =
      item.subtitles
      |> Enum.at(String.to_integer(index))

    {:ok, _sub} = Subtitles.delete_subtitle(subtitle)

    item = Registeries.get_registery!(registery_id)
    render(conn, "show.json", item: item)
  end
end
