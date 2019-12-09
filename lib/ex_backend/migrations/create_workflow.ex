defmodule ExBackend.Migration.CreateWorkflow do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:workflow) do
      add(:reference, :string)
      add(:flow, :map)

      timestamps()
    end
  end
end
