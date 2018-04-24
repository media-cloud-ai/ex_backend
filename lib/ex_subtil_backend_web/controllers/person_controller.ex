defmodule ExSubtilBackendWeb.PersonController do
  use ExSubtilBackendWeb, :controller

  import ExSubtilBackendWeb.Authorize

  alias ExSubtilBackend.Persons
  alias ExSubtilBackend.Persons.Person

  action_fallback(ExSubtilBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :show, :update, :delete])
  plug(:right_editor_check when action in [:index, :show, :update, :delete])

  def index(conn, params) do
    persons = Persons.list_persons(params)
    render(conn, "index.json", persons: persons)
  end

  def create(conn, %{"person" => person_params}) do
    case Persons.create_person(person_params) do
      {:ok, %Person{} = person} ->
        conn
        |> put_status(:created)
        |> render("show.json", person: person)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ExSubtilBackendWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    person = Persons.get_person!(id)
    render(conn, "show.json", person: person)
  end

  def update(conn, %{"id" => id, "person" => person_params}) do
    person = Persons.get_person!(id)

    with {:ok, %Person{} = person} <- Persons.update_person(person, person_params) do
      render(conn, "show.json", person: person)
    end
  end

  def delete(conn, %{"id" => id}) do
    person = Persons.get_person!(id)

    with {:ok, %Person{}} <- Persons.delete_person(person) do
      send_resp(conn, :no_content, "")
    end
  end
end
