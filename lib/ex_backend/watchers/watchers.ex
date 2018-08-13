defmodule ExBackend.Watchers do
  @moduledoc """
  The Watchers context.
  """

  import Ecto.Query, warn: false
  alias ExBackend.Repo

  alias ExBackend.Watchers.Watcher

  defp force_integer(param) when is_bitstring(param) do
    param
    |> String.to_integer()
  end

  defp force_integer(param) do
    param
  end

  @doc """
  Returns the list of watchers.

  ## Examples

      iex> list_watchers()
      [%Watcher{}, ...]

  """
  def list_watchers(params \\ %{}) do
    page =
      Map.get(params, "page", 0)
      |> force_integer

    size =
      Map.get(params, "size", 10)
      |> force_integer

    offset = page * size

    query =
      case Map.get(params, :identifier, nil) || Map.get(params, "identifier", nil) do
        nil ->
          from(watcher in Watcher)

        identifier ->
          from(watcher in Watcher, where: watcher.identifier == ^identifier)
      end

    total_query = from(item in query, select: count(item.id))

    total =
      Repo.all(total_query)
      |> List.first()

    query =
      from(
        watcher in query,
        order_by: [desc: :inserted_at],
        offset: ^offset,
        limit: ^size
      )

    watchers = Repo.all(query)

    %{
      data: watchers,
      total: total,
      page: page,
      size: size
    }
  end

  @doc """
  Gets a single watcher.

  Raises `Ecto.NoResultsError` if the Watcher does not exist.

  ## Examples

      iex> get_watcher!(123)
      %Watcher{}

      iex> get_watcher!(456)
      ** (Ecto.NoResultsError)

  """
  def get_watcher!(id), do: Repo.get!(Watcher, id)

  @doc """
  Creates a watcher.

  ## Examples

      iex> create_watcher(%{field: value})
      {:ok, %Watcher{}}

      iex> create_watcher(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_watcher(attrs \\ %{}) do
    %Watcher{}
    |> Watcher.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a watcher.

  ## Examples

      iex> update_watcher(watcher, %{field: new_value})
      {:ok, %Watcher{}}

      iex> update_watcher(watcher, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_watcher(%Watcher{} = watcher, attrs) do
    watcher
    |> Watcher.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Watcher.

  ## Examples

      iex> delete_watcher(watcher)
      {:ok, %Watcher{}}

      iex> delete_watcher(watcher)
      {:error, %Ecto.Changeset{}}

  """
  def delete_watcher(%Watcher{} = watcher) do
    Repo.delete(watcher)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking watcher changes.

  ## Examples

      iex> change_watcher(watcher)
      %Ecto.Changeset{source: %Watcher{}}

  """
  def change_watcher(%Watcher{} = watcher) do
    Watcher.changeset(watcher, %{})
  end
end
