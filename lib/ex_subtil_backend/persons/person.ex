defmodule ExSubtilBackend.Persons.Person do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExSubtilBackend.Persons.Person

  schema "persons" do
    field(:last_name, :string)
    field(:first_names, {:array, :string})
    field(:birthday_date, :date)
    field(:birthday_city, :string, default: "")
    field(:birthday_country, :string, default: "")
    field(:nationalities, {:array, :string}, default: [])
    field(:links, :map, defaut: %{})

    timestamps()
  end

  @doc false
  def changeset(%Person{} = job, attrs) do
    job
    |> cast(attrs, [
      :last_name,
      :first_names,
      :birthday_date,
      :birthday_city,
      :birthday_country,
      :nationalities,
      :links
    ])
    |> validate_required([:last_name, :first_names, :birthday_date])
  end
end
