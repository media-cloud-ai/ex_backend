defmodule ExBackend.Subtitles.Subtitle do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExBackend.Registeries.Registery
  alias ExBackend.Subtitles.Subtitle
  alias ExBackend.Accounts.User

  schema "subtitles" do
    field(:language, :string)
    field(:version, :string)
    field(:path, :string)
    belongs_to(:user, User, foreign_key: :user_id)
    belongs_to(:parent, Subtitle, foreign_key: :parent_id)
    belongs_to(:registery, Registery, foreign_key: :registery_id)
    has_many(:childs, Subtitle, foreign_key: :parent_id, on_delete: :nothing)

    timestamps()
  end

  @doc false
  def changeset(%Subtitle{} = subtitle, attrs) do
    subtitle
    |> cast(attrs, [:language, :version, :path, :user_id, :registery_id, :parent_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:registery_id)
    |> foreign_key_constraint(:parent_id)
    |> validate_required([:language, :version, :path, :user_id, :registery_id])
  end
end
