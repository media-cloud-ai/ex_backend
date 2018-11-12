defmodule ExBackendWeb.PlayerController do
  use ExBackendWeb, :controller

  action_fallback(ExBackendWeb.FallbackController)

  def manifest(conn, %{"content" => content}) do
    root =
      System.get_env("ROOT_DASH_CONTENT") || Application.get_env(:ex_backend, :root_dash_content)

    conn
    |> put_resp_header("Accept-Ranges", "bytes")
    |> put_resp_header("Access-Control-Allow-Credentials", "true, false")
    |> put_resp_header("Access-Control-Allow-Headers", "origin,range,hdntl,hdnts")
    |> put_resp_header("Access-Control-Allow-Methods", "GET")
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Expose-Headers", "Server,range,hdntl,hdnts")
    |> send_file(200, Path.join([root, content, "manifest.mpd"]))
  end

  def index(conn, %{"content" => content, "filename" => filename}) do
    root =
      System.get_env("ROOT_DASH_CONTENT") || Application.get_env(:ex_backend, :root_dash_content)

    if String.ends_with?(filename, ".ttml") || String.ends_with?(filename, ".vtt") do
      send_file(conn, 200, Path.join([root, content, filename]))
    else
      {"range", range} =
        conn.req_headers
        |> Enum.find(fn {key, _value} -> key == "range" end)

      [start_pos, end_pos] =
        range
        |> String.split("=")
        |> List.last()
        |> String.split("-")

      path = Path.join([root, content, filename])
      stat = File.stat!(path)

      {:ok, file} = :file.open(path, [:read, :binary])
      start = start_pos |> String.to_integer()
      length = (end_pos |> String.to_integer()) - start + 1

      {:ok, data} = :file.pread(file, start, length)
      :file.close(file)

      conn
      |> put_resp_header("content-range", "bytes #{start}-#{end_pos}/#{stat.size}")
      |> put_resp_header("content-type", "video/mp4")
      |> send_resp(200, data)
    end
  end
end
