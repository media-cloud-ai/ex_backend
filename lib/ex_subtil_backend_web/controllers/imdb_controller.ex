defmodule ExSubtilBackendWeb.ImdbController do
  use ExSubtilBackendWeb, :controller

  import ExSubtilBackendWeb.Authorize

  action_fallback(ExSubtilBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:show])
  plug(:right_editor_check when action in [:show])

  def index(conn, %{"query" => query}) do
    first_letter = query |> String.first() |> String.downcase()

    url = "https://v2.sg.media-imdb.com/suggests/names/#{first_letter}/#{query}.json"

    body = HTTPoison.get!(url).body

    response =
      String.slice(body, 6 + String.length(query)..-2)
      |> Poison.decode!

    conn
    |> json(response)
  end

  def show(conn, %{"id" => id}) do
    people = ExIMDbSniffer.people(id)
    render(conn, "show.json", people: people)
  end
end
