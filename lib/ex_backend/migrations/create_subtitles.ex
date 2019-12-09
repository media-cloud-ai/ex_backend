defmodule ExBackend.Migration.CreateSubtitles do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:subtitles) do
      add(:language, :string)
      add(:version, :string)
      add(:path, :string)
      add(:user_id, references(:users, on_delete: :nothing))
      add(:registery_id, references(:registery, on_delete: :nothing))
      add(:parent_id, references(:subtitles, on_delete: :nothing))

      timestamps()
    end
  end
end
