defmodule ExBackend.Credentials.Credential do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias ExBackend.Credentials.Credential

  schema "credentials" do
    field(:key, :string)
    field(:value, :string)
    timestamps()
  end

  @doc false
  def changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs, [:key, :value])
    |> unique_constraint(:key)
    |> validate_required([:key, :value])
  end
end
