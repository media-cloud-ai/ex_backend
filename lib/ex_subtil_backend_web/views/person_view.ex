defmodule ExSubtilBackendWeb.PersonView do
  use ExSubtilBackendWeb, :view
  alias ExSubtilBackendWeb.PersonView

  def render("index.json", %{persons: %{data: persons, total: total}}) do
    %{
      data: render_many(persons, PersonView, "person.json"),
      total: total
    }
  end

  def render("show.json", %{person: person}) do
    %{data: render_one(person, PersonView, "person.json")}
  end

  def render("person.json", %{person: person}) do
    %{
      id: person.id,
      last_name: person.last_name,
      first_names: person.first_names,
      birthday_date: person.birthday_date,
      birthday_city: person.birthday_city,
      birthday_country: person.birthday_country,
      nationalities: person.nationalities,
      links: person.links,
      inserted_at: person.inserted_at,
      updated_at: person.updated_at
    }
  end
end
