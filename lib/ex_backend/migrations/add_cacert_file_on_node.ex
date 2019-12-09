defmodule ExBackend.Migration.AddCacertFileOnNode do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:nodes) do
      add(:cacertfile, :string)
    end
  end
end
