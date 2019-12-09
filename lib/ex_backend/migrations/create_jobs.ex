defmodule ExBackend.Migration.CreateJobs do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:jobs) do
      add(:name, :string)
      add(:params, :map)

      timestamps()
    end
  end
end
