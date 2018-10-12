defmodule ExBackend.Registeries.Registery do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExBackend.Registeries.Registery
  alias ExBackend.Workflows.Workflow
  alias ExBackend.Subtitles.Subtitle

  schema "registery" do
    field(:name, :string)
    field(:params, :map)
    belongs_to(:workflow, Workflow, foreign_key: :workflow_id)
    has_many(:subtitles, Subtitle, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(%Registery{} = registery, attrs) do
    registery
    |> cast(attrs, [:name, :params, :workflow_id])
    |> foreign_key_constraint(:workflow_id)
    |> validate_required([:name, :params, :workflow_id])
  end
end
