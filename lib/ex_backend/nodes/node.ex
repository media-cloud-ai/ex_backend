defmodule ExBackend.Nodes.Node do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias ExBackend.Nodes.Node

  schema "nodes" do
    field(:label, :string)
    field(:hostname, :string)
    field(:port, :integer)
    field(:cacertfile, :string)
    field(:certfile, :string)
    field(:keyfile, :string)
    timestamps()
  end

  @doc false
  def changeset(%Node{} = nnode, attrs) do
    nnode
    |> cast(attrs, [:label, :hostname, :port, :cacertfile, :certfile, :keyfile])
    |> validate_required([:label, :hostname, :port])
  end
end
