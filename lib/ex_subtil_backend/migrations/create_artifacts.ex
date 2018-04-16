defmodule ExSubtilBackend.Migration.CreateArtifacts do
  use Ecto.Migration

  def change do
    create table(:artifacts) do
      add(:resources, :map)
      add(:workflow_id, references(:workflow, on_delete: :nothing))

      timestamps()
    end
  end
end
