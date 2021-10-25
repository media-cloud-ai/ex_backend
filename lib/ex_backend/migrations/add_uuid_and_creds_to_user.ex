defmodule ExBackend.Migration.AddUuidAndCredsToUser do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:uuid, :string, default: Ecto.UUID.generate())
    end

    alter table(:users) do
      add(:access_key_id, :string)
      add(:secret_access_key, :string)
    end
  end
end
