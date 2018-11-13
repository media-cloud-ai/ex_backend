defmodule ExBackend.Migration.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add(:key, :string)
      add(:value, :string)
      timestamps()
    end
  end
end
