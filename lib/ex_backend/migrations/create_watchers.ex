defmodule ExBackend.Migration.CreateWatchers do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:watchers) do
      add(:identifier, :string)
      add(:last_event, :utc_datetime)

      timestamps()
    end

    create(unique_index(:watchers, [:identifier]))
  end
end
