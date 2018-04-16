defmodule ExSubtilBackend.Migration.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add(:name, :string)
      add(:params, :map)

      timestamps()
    end
  end
end
