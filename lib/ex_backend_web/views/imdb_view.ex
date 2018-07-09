defmodule ExBackendWeb.ImdbView do
  use ExBackendWeb, :view

  def render("show.json", %{people: people}) do
    %{
      name: people.name,
      birth_date: people.birth_date,
      birth_location: people.birth_location,
      picture_url: people.picture_url
    }
  end

end
