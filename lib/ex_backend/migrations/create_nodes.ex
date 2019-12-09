defmodule ExBackend.Migration.CreateNodes do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:nodes) do
      add(:label, :string)
      add(:hostname, :string)
      add(:port, :integer)
      add(:certfile, :string)
      add(:keyfile, :string)
      timestamps()
    end
  end
end
