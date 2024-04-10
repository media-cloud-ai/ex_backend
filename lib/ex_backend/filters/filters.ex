defmodule ExBackend.Filters do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias ExBackend.Accounts.User
  alias ExBackend.Filters
  alias ExBackend.Repo

  import EctoEnum

  defenum(FilterType, [
    "workflow"
  ])

  schema "filters" do
    field(:name, :string)
    field(:type, FilterType)
    field(:filters, :map, default: %{})
    field(:active, :boolean, default: true)

    belongs_to(:user, User)

    timestamps()
  end

  def changeset(%Filters{} = filters, params \\ %{}) do
    filters
    |> cast(params, [:name, :type, :filters, :user_id, :active])
    |> validate_required([:name, :type, :filters, :user_id])
  end

  def get(id), do: Repo.get(Filters, id)

  def list_workflow_filter_for_user(%{"user_id" => user_id}) do
    from(
      filter in Filters,
      where:
        filter.user_id == ^user_id and
          filter.type == :workflow and
          filter.active == true,
      select: %{id: filter.id, name: filter.name, filter: filter.filters}
    )
    |> Repo.all()
  end

  def save_user_workflow_filters(attrs) do
    %Filters{}
    |> Filters.changeset(attrs)
    |> Repo.insert()
  end

  def delete_user_workflow_filter(filter) do
    filter
    |> Filters.changeset(%{active: false})
    |> Repo.update()
  end
end
