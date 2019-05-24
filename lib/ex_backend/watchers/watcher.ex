defmodule ExBackend.Watchers.Watcher do
  use Ecto.Schema
  import Ecto.Changeset
  alias ExBackend.Watchers.Watcher

  schema "watchers" do
    field(:identifier, :string)
    field(:last_event, :utc_datetime_usec)

    timestamps()
  end

  @doc false
  def changeset(%Watcher{} = watcher, attrs) do
    watcher
    |> cast(attrs, [
      :identifier,
      :last_event
    ])
    |> validate_required([:identifier])
  end
end
