defmodule ExBackend.Migration.CreateFilters do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:filters) do
      add(:name, :string)
      add(:type, :string)
      add(:filters, :map, default: %{})
      add(:active, :boolean)
      add(:user_id, references(:users))
      timestamps()
    end
  end
end
