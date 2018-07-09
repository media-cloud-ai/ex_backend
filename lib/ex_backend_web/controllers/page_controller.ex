defmodule ExBackendWeb.PageController do
  use ExBackendWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
