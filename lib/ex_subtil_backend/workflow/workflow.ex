defmodule ExSubtilBackend.Workflows.Workflow do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExSubtilBackend.Workflows.Workflow
  alias ExSubtilBackend.Jobs.Job
  alias ExSubtilBackend.Artifacts.Artifact

  schema "workflow" do
    field(:reference, :string)
    field(:flow, :map)
    has_many(:jobs, Job, on_delete: :delete_all)
    has_many(:artifacts, Artifact, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(%Workflow{} = workflow, attrs) do
    workflow
    |> cast(attrs, [:reference, :flow])
    |> validate_required([:reference, :flow])
  end
end
