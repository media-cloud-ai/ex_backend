defmodule ExBackend.Migration.AddStatusDescription do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:status) do
      add(:description, :map)
    end
  end
end
