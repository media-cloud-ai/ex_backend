defmodule ExBackend.Migration.AddFieldsOnWorkflow do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:workflow) do
      add(:identifier, :string, default: "")
      add(:version_major, :integer, default: 0)
      add(:version_minor, :integer, default: 0)
      add(:version_micro, :integer, default: 0)
      add(:tags, {:array, :string}, default: [])
    end
  end
end
