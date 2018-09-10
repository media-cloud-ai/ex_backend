defmodule ExBackend.Registeries do
  @moduledoc """
  The Registeries context.
  """

  import Ecto.Query, warn: false
  alias ExBackend.Repo

  alias ExBackend.Registeries.Registery


  defp force_integer(param) when is_bitstring(param) do
    param
    |> String.to_integer()
  end

  defp force_integer(param) do
    param
  end

  @doc """
  Returns the list of registeries.

  ## Examples

      iex> list_registeries()
      [%Registery{}, ...]

  """
  def list_registeries(params \\ %{}) do
    page =
      Map.get(params, "page", 0)
      |> force_integer

    size =
      Map.get(params, "size", 10)
      |> force_integer

    offset = page * size

    query = from(registery in Registery)

    query =
      case Map.get(params, "workflow_id") do
        nil ->
          query

        str_workflow_id ->
          workflow_id = force_integer(str_workflow_id)
          from(registery in query, where: registery.workflow_id == ^workflow_id)
      end

    query =
      case Map.get(params, "name") do
        nil ->
          query

        name ->
          from(registery in query, where: registery.name == ^name)
      end

    total_query = from(item in query, select: count(item.id))

    total =
      Repo.all(total_query)
      |> List.first()

    query =
      from(
        registery in query,
        order_by: [desc: :inserted_at],
        offset: ^offset,
        limit: ^size
      )

    items =
      Repo.all(query)

    %{
      data: items,
      total: total,
      page: page,
      size: size
    }
  end

  @doc """
  Gets a single Registery.

  Raises `Ecto.NoResultsError` if the Registery does not exist.

  ## Examples

      iex> get_registery!(123)
      %Registery{}

      iex> get_registery!(456)
      ** (Ecto.NoResultsError)

  """
  def get_registery!(id), do: Repo.get!(Registery, id)

  @doc """
  Creates a registery.

  ## Examples

      iex> create_registery(%{field: value})
      {:ok, %Registery{}}

      iex> create_registery(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registery(attrs \\ %{}) do
    %Registery{}
    |> Registery.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a registery.

  ## Examples

      iex> update_registery(registery, %{field: new_value})
      {:ok, %Registery{}}

      iex> update_registery(registery, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_registery(%Registery{} = registery, attrs) do
    registery
    |> Registery.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Registery.

  ## Examples

      iex> delete_registery(registery)
      {:ok, %Registery{}}

      iex> delete_registery(registery)
      {:error, %Ecto.Changeset{}}

  """
  def delete_registery(%Registery{} = registery) do
    Repo.delete(registery)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registery changes.

  ## Examples

      iex> change_registery(registery)
      %Ecto.Changeset{source: %Registery{}}

  """
  def change_registery(%Registery{} = registery) do
    Registery.changeset(registery, %{})
  end
end
