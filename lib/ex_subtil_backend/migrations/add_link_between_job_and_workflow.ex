defmodule ExSubtilBackend.Migration.AddLinkBetweenJobAndWorkflow do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :workflow_id, references(:workflow, on_delete: :nothing)
    end
  end
end
