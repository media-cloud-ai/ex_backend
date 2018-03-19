defmodule ExSubtilBackend.Workflows do
  @moduledoc """
  The Workflows context.
  """

  import Ecto.Query, warn: false
  alias ExSubtilBackend.Repo

  alias ExSubtilBackend.Workflows.Workflow
  alias ExSubtilBackend.Jobs.Job

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

    query =
      case Map.get(params, :video_id, nil) || Map.get(params, "video_id", nil) do
        nil ->
          from workflow in Workflow
        video_id ->
          from workflow in Workflow,
            where: workflow.reference == ^video_id
      end

    total_query = from item in query,
      select: count(item.id)

    total =
      Repo.all(total_query)
      |> List.first

    query = from workflow in query,
      order_by: [desc: :inserted_at],
      offset: ^offset,
      limit: ^size

    workflows =
      Repo.all(query)
      |> preload_workflows
      |> Repo.preload(:jobs)

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
  def get_workflow!(id) do
    Repo.get!(Workflow, id)
    |> preload_workflow
  end

  defp preload_workflow(workflow) do
    steps =
      workflow
      |> Map.get(:flow)
      |> Map.get("steps")
      |> get_step_status(workflow.id)

    Map.put(workflow, :flow, %{steps: steps})
  end

  defp preload_workflows(workflows, result \\ [])
  defp preload_workflows([], result), do: result
  defp preload_workflows([workflow | workflows], result) do
    result = List.insert_at(result, -1, workflow |> preload_workflow)
    preload_workflows(workflows, result)
  end

  defp get_step_status(steps, workflow_id, result \\[])
  defp get_step_status([], _workflow_id, result), do: result
  defp get_step_status([step | steps], workflow_id, result) do
    id = Map.get(step, "id")

    query = from item in Job,
      join: w in assoc(item, :workflow), where: w.id == ^workflow_id,
      where: item.name == ^id

    jobs =
      Repo.all(query)
      |> Repo.preload(:status)

    status =
      jobs
      |> get_current_status

    status =
      case length(jobs) do
        0 -> "queued"
        _ -> status
      end

    completed = count_status(jobs, "completed")
    errors = count_status(jobs, "error")
    queued = count_queued_status(jobs)

    job_status = %{
      total: length(jobs),
      completed: completed,
      errors: errors,
      queued: queued,
    }

    step =
      step
      |> Map.put(:status, status)
      |> Map.put(:jobs, job_status)

    result = List.insert_at(result, -1, step)
    get_step_status(steps, workflow_id, result)
  end

  defp count_status(jobs, status, count \\ 0)
  defp count_status([], _status, count), do: count
  defp count_status([job | jobs], status, count) do

    count =
      case Enum.map(job.status, fn s -> s.state end) |> List.last do
        nil -> count
        state ->
          if state == status do
            count + 1
          else
            count
          end
      end

    count_status(jobs, status, count)
  end

  defp count_queued_status(jobs, count \\ 0)
  defp count_queued_status([], count), do: count
  defp count_queued_status([job | jobs], count) do

    count =
      case Enum.map(job.status, fn s -> s.state end) |> List.last do
        nil -> count + 1
        state -> count
      end

    count_queued_status(jobs, count)
  end

  defp get_current_status([]), do: "processing"
  defp get_current_status([job | jobs]) do
    if Enum.count(job.status, fn(x) -> x.state == "completed" end) > 0 do
      "completed"
    else
      get_current_status(jobs)
    end
  end

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
