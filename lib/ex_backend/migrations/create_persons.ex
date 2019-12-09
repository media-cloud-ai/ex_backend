defmodule ExBackend.Migration.CreatePersons do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:persons) do
      add(:last_name, :string)
      add(:first_names, {:array, :string})
      add(:birthday_date, :date)
      add(:birthday_city, :string)
      add(:birthday_country, :string)
      add(:nationalities, {:array, :string})
      add(:links, :map)

      timestamps()
    end
  end
end
