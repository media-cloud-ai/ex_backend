defmodule ExBackend.Persons.Person do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExBackend.Persons.Person

  schema "persons" do
    field(:last_name, :string)
    field(:first_names, {:array, :string})
    field(:gender, :string, default: "")
    field(:birth_date, :date)
    field(:birth_city, :string, default: "")
    field(:birth_country, :string, default: "")
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
      :gender,
      :birth_date,
      :birth_city,
      :birth_country,
      :nationalities,
      :links
    ])
    |> validate_required([:last_name, :first_names, :gender, :birth_date])
  end
end
