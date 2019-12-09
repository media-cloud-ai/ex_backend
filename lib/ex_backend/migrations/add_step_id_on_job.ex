defmodule ExBackend.Migration.AddStepIdOnJob do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add(:step_id, :integer, default: 0)
    end
  end
end
