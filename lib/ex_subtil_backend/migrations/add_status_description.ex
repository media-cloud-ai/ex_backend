defmodule ExSubtilBackend.Migration.AddStatusDescription do
  use Ecto.Migration

  def change do
    alter table(:status) do
      add(:description, :map)
    end
  end
end
