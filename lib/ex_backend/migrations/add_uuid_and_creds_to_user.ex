defmodule ExBackend.Migration.AddUuidAndCredsToUser do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:uuid, :string,
        default:
          :crypto.strong_rand_bytes(40)
          |> Base.url_encode64(padding: true)
      )
    end

    alter table(:users) do
      add(:access_key_id, :string)
      add(:secret_access_key, :string)
    end
  end
end
