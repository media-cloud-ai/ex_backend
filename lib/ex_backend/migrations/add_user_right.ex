defmodule ExBackend.Migration.AddUserRight do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:rights, {:array, :string}, default: [])
    end
  end
end
