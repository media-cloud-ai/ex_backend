defmodule ExSubtilBackend.Migration.CreateWorkflow do
  use Ecto.Migration

  def change do
    create table(:workflow) do
      add(:reference, :string)
      add(:flow, :map)

      timestamps()
    end
  end
end
