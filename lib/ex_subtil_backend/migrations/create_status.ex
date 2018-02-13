defmodule ExSubtilBackend.Migration.CreateStatus do
  use Ecto.Migration

  def change do
    create table(:status) do
      add :state, :string
      add :job_id, references(:jobs, on_delete: :nothing)

      timestamps()
    end

    create index(:status, [:job_id])
  end
end
