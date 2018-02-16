defmodule ExSubtilBackend.Workflows do
  @moduledoc """
  The Workflows context.
  """

  import Ecto.Query, warn: false
  alias ExSubtilBackend.Repo

  alias ExSubtilBackend.Workflows.Workflow

  defp force_integer(param) when is_bitstring(param) do
    param
    |> String.to_integer
  end

  defp force_integer(param) do
    param
  end

  @doc """
  Returns the list of workflows.

  ## Examples

      iex> list_workflows()
      [%Workflow{}, ...]

  """
  def list_workflows(params) do

    page =
      Map.get(params, "page", 0)
      |> force_integer
    size =
      Map.get(params, "size", 10)
      |> force_integer

    offset = page * size

    total_query = from item in Workflow,
      select: count(item.id)

    total =
      Repo.all(total_query)
      |> List.first

    query = from workflow in Workflow,
      order_by: [desc: :inserted_at],
      offset: ^offset,
      limit: ^size

    workflows =
      Repo.all(query)

    %{
      data: workflows,
      total: total,
      page: page,
      size: size
    }
  end

  @doc """
  Gets a single workflows.

  Raises `Ecto.NoResultsError` if the Workflow does not exist.

  ## Examples

      iex> get_workflows!(123)
      %Workflow{}

      iex> get_workflows!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workflow!(id), do: Repo.get!(Workflow, id)

  @doc """
  Creates a workflow.

  ## Examples

      iex> create_workflow(%{field: value})
      {:ok, %Workflow{}}

      iex> create_workflow(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workflow(attrs \\ %{}) do
    %Workflow{}
    |> Workflow.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a workflow.

  ## Examples

      iex> update_workflow(workflow, %{field: new_value})
      {:ok, %Workflow{}}

      iex> update_workflow(workflow, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workflow(%Workflow{} = workflow, attrs) do
    workflow
    |> Workflow.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Workflow.

  ## Examples

      iex> delete_workflow(workflow)
      {:ok, %Workflow{}}

      iex> delete_workflow(workflow)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workflow(%Workflow{} = workflow) do
    Repo.delete(workflow)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workflow changes.

  ## Examples

      iex> change_workflow(workflow)
      %Ecto.Changeset{source: %Workflow{}}

  """
  def change_workflow(%Workflow{} = workflow) do
    Workflow.changeset(workflow, %{})
  end

  def jobs_without_status?(workflow_id, status \\ "completed") do
    query_count_jobs = from workflow in Workflow,
      where: workflow.id == ^workflow_id,
      join: jobs in assoc(workflow, :jobs),
      select: count(jobs.id)

    query_count_state = from workflow in Workflow,
      where: workflow.id == ^workflow_id,
      join: jobs in assoc(workflow, :jobs),
      join: status in assoc(jobs, :status),
      where: status.state == ^status,
      select: count(status.id)

    total =
      Repo.all(query_count_jobs)
      |> List.first

    researched =
      Repo.all(query_count_state)
      |> List.first

    total == researched
  end
end
