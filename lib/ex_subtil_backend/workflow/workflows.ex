defmodule ExSubtilBackend.Workflows do
  @moduledoc """
  The Workflows context.
  """

  import Ecto.Query, warn: false
  alias ExSubtilBackend.Repo

  alias ExSubtilBackend.Workflows.Workflow
  alias ExSubtilBackend.Jobs

  defp force_integer(param) when is_bitstring(param) do
    param
    |> String.to_integer()
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
  def list_workflows(params \\ %{}) do
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
          from(workflow in Workflow)

        video_id ->
          from(workflow in Workflow, where: workflow.reference == ^video_id)
      end

    status = Map.get(params, "state", [])

    query =
      if not "completed" in status do
        from(
          workflow in query,
          left_join: artifact in assoc(workflow, :artifacts),
          where: is_nil(artifact.id)
        )
      else
        query
      end

    total_query = from(item in query, select: count(item.id))

    total =
      Repo.all(total_query)
      |> List.first()

    query =
      from(
        workflow in query,
        order_by: [desc: :inserted_at],
        offset: ^offset,
        limit: ^size
      )

    workflows =
      Repo.all(query)
      |> Repo.preload([:jobs, :artifacts])
      |> preload_workflows

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
    |> Repo.preload([:jobs, :artifacts])
    |> preload_workflow
  end

  defp preload_workflow(workflow) do
    jobs = Repo.preload(workflow.jobs, :status)

    steps =
      workflow
      |> Map.get(:flow)
      |> Map.get("steps")
      |> get_step_status(jobs)

    workflow
    |> Map.put(:flow, %{steps: steps})
    |> Map.put(:jobs, jobs)
  end

  defp preload_workflows(workflows, result \\ [])
  defp preload_workflows([], result), do: result

  defp preload_workflows([workflow | workflows], result) do
    result = List.insert_at(result, -1, workflow |> preload_workflow)
    preload_workflows(workflows, result)
  end

  defp get_step_status(steps, workflow_jobs, result \\ [])
  defp get_step_status([], _workflow_jobs, result), do: result
  defp get_step_status(nil, _workflow_jobs, result), do: result

  defp get_step_status([step | steps], workflow_jobs, result) do
    name = Map.get(step, "name")
    jobs = Enum.filter(workflow_jobs, fn job -> job.name == name end)

    completed = count_status(jobs, "completed")
    errors = count_status(jobs, "error")
    skipped = count_status(jobs, "skipped")
    queued = count_queued_status(jobs)

    job_status = %{
      total: length(jobs),
      completed: completed,
      errors: errors,
      queued: queued,
      skipped: skipped
    }

    status =
      cond do
        errors > 0 -> "error"
        queued > 0 -> "processing"
        skipped > 0 -> "skipped"
        completed > 0 -> "completed"
        true -> "queued"
      end

    step =
      step
      |> Map.put(:status, status)
      |> Map.put(:jobs, job_status)

    result = List.insert_at(result, -1, step)
    get_step_status(steps, workflow_jobs, result)
  end

  defp count_status(jobs, status, count \\ 0)
  defp count_status([], _status, count), do: count

  defp count_status([job | jobs], status, count) do
    count =
      case Enum.map(job.status, fn s -> s.state end) |> List.last() do
        nil ->
          count

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
      case Enum.map(job.status, fn s -> s.state end) |> List.last() do
        nil -> count + 1
        _state -> count
      end

    count_queued_status(jobs, count)
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

  def notification_from_job(job_id) do
    job = Jobs.get_job!(job_id)
    topic = "update_workflow_" <> Integer.to_string(job.workflow_id)

    ExSubtilBackendWeb.Endpoint.broadcast!("notifications:all", topic, %{
      body: %{workflow_id: job.workflow_id}
    })
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

  def jobs_without_status?(workflow_id, status \\ ["completed", "skipped"]) do
    query_count_jobs =
      from(
        workflow in Workflow,
        where: workflow.id == ^workflow_id,
        join: jobs in assoc(workflow, :jobs),
        select: count(jobs.id)
      )

    query_count_state =
      from(
        workflow in Workflow,
        where: workflow.id == ^workflow_id,
        join: jobs in assoc(workflow, :jobs),
        join: status in assoc(jobs, :status),
        where: status.state in ^status,
        select: count(status.id)
      )

    total =
      Repo.all(query_count_jobs)
      |> List.first()

    researched =
      Repo.all(query_count_state)
      |> List.first()

    total == researched
  end
end
