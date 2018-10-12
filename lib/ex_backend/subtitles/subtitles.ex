defmodule ExBackend.Subtitles do
  @moduledoc """
  The Subtitles context.
  """

  import Ecto.Query, warn: false
  alias ExBackend.Repo

  alias ExBackend.Subtitles.Subtitle

  defp force_integer(param) when is_bitstring(param) do
    param
    |> String.to_integer()
  end

  defp force_integer(param) do
    param
  end

  @doc """
  Returns the list of subtitles.

  ## Examples

      iex> list_subtitles()
      [%Subtitle{}, ...]

  """
  def list_subtitles(params \\ %{}) do
    page =
      Map.get(params, "page", 0)
      |> force_integer

    size =
      Map.get(params, "size", 10)
      |> force_integer

    offset = page * size

    query = from(subtitle in Subtitle)

    query =
      case Map.get(params, "version") do
        nil ->
          query

        str_workflow_id ->
          version = force_integer(str_workflow_id)
          from(subtitle in query, where: subtitle.version == ^version)
      end

    query =
      case Map.get(params, "language") do
        nil ->
          query

        language ->
          from(subtitle in query, where: subtitle.language == ^language)
      end

    total_query = from(item in query, select: count(item.id))

    total =
      Repo.all(total_query)
      |> List.first()

    query =
      from(
        subtitle in query,
        order_by: [desc: :inserted_at],
        offset: ^offset,
        limit: ^size
      )

    items = Repo.all(query)

    %{
      data: items,
      total: total,
      page: page,
      size: size
    }
  end

  @doc """
  Gets a single Subtitle.

  Raises `Ecto.NoResultsError` if the Subtitle does not exist.

  ## Examples

      iex> get_subtitle!(123)
      %Subtitle{}

      iex> get_subtitle!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subtitle!(id), do: Repo.get!(Subtitle, id)

  @doc """
  Creates a subtitle.

  ## Examples

      iex> create_subtitle(%{field: value})
      {:ok, %Subtitle{}}

      iex> create_subtitle(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subtitle(attrs \\ %{}) do
    %Subtitle{}
    |> Subtitle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subtitle.

  ## Examples

      iex> update_subtitle(subtitle, %{field: new_value})
      {:ok, %Subtitle{}}

      iex> update_subtitle(subtitle, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subtitle(%Subtitle{} = subtitle, attrs) do
    subtitle
    |> Subtitle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Subtitle.

  ## Examples

      iex> delete_subtitle(subtitle)
      {:ok, %Subtitle{}}

      iex> delete_subtitle(subtitle)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subtitle(%Subtitle{} = subtitle) do
    Repo.delete(subtitle)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subtitle changes.

  ## Examples

      iex> change_subtitle(subtitle)
      %Ecto.Changeset{source: %Subtitle{}}

  """
  def change_subtitle(%Subtitle{} = subtitle) do
    Subtitle.changeset(subtitle, %{})
  end
end
