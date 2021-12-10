defmodule ExBackend.Migration.ReplaceUserRightsPerRoles do
  @moduledoc false

  use Ecto.Migration

  def change do
    rename(table(:users), :rights, to: :roles)
  end

end
