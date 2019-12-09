defmodule ExBackend.Migration.RemoveParamsFromJob do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:jobs) do
      remove(:params)
    end
  end
end
