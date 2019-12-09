defmodule ExBackend.Migration.AddParametersOnJob do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add(:parameters, {:array, :map}, default: [])
    end
  end
end
