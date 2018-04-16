defmodule ExSubtilBackend.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExSubtilBackend.Jobs.Job
  alias ExSubtilBackend.Jobs.Status
  alias ExSubtilBackend.Workflows.Workflow

  schema "jobs" do
    field(:name, :string)
    field(:params, :map)
    belongs_to(:workflow, Workflow, foreign_key: :workflow_id)
    has_many(:status, Status, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(%Job{} = job, attrs) do
    job
    |> cast(attrs, [:name, :params, :workflow_id])
    |> foreign_key_constraint(:workflow_id)
    |> validate_required([:name, :params, :workflow_id])
  end
end
