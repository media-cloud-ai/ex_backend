defmodule ExBackend.Migration.UpdateCredentialValueLength do
  use Ecto.Migration

  def change do
    alter table(:credentials) do
      modify :value, :text
    end
  end
end
