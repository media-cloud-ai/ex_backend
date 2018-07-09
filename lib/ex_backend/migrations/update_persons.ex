defmodule ExBackend.Migration.UpdatePersons do
  use Ecto.Migration

  def change do
    rename table(:persons), :birthday_date, to: :birth_date
    rename table(:persons), :birthday_city, to: :birth_city
    rename table(:persons), :birthday_country, to: :birth_country

    alter table(:persons) do
      add(:gender, :string)
    end
  end
end
