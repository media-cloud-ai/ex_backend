defmodule ExSubtilBackend.Artifacts do
  @moduledoc """
  The Artifacts context.
  """

  import Ecto.Query, warn: false
  alias ExSubtilBackend.Repo

  alias ExSubtilBackend.Artifacts.Artifact


  @doc """
  Creates a artifact.

  ## Examples

      iex> create_artifact(%{field: value})
      {:ok, %Artifact{}}

      iex> create_artifact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_artifact(attrs \\ %{}) do
    %Artifact{}
    |> Artifact.changeset(attrs)
    |> Repo.insert()
  end
end
