defmodule ExBackend.Migration.UpdateCredentialValueLength do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:credentials) do
      modify(:value, :text)
    end
  end
end
