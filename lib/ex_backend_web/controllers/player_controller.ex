defmodule ExBackendWeb.PlayerController do
  use ExBackendWeb, :controller

  # import ExBackendWeb.Authorize
  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  # plug(:user_check when action in [:index])
  # plug(:right_editor_check when action in [:index])

  def manifest(conn, params) do
    send_file(conn, 200, "/Users/marco/media/la_vie/manifest.mpd")
  end

  def index(conn, %{"filename" => filename}) do

    {"range", range} =
      conn.req_headers
      |> Enum.find(fn {key, _value} -> key == "range" end)

    [start_pos, end_pos] =
      range
      |> String.split("=")
      |> List.last
      |> String.split("-")


    path = "/Users/marco/media/la_vie/" <> filename
    stat = File.stat!(path)

    {:ok, file} = :file.open(path, [:read, :binary])
    start = start_pos |> String.to_integer
    length = (end_pos |> String.to_integer) - start + 1
    # IO.puts "get from #{start} to #{end_pos}: #{length} bytes"

    {ok, data} = :file.pread(file, start, length)
    :file.close(file)

    conn
    |> put_resp_header("content-range", "bytes #{start}-#{end_pos}/#{stat.size}")
    # |> put_resp_header("content-length", "#{stat.size}")
    |> put_resp_header("content-type", "video/mp4")
    |> send_resp(200, data)
  end
end
