defmodule ExBackend.Migration.CreateRegistery do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:registery) do
      add(:name, :string)
      add(:params, :map)
      add(:workflow_id, references(:workflow, on_delete: :nothing))

      timestamps()
    end
  end
end
