defmodule ExBackend.Workflow.Step.Requirements do
  alias ExBackend.Credentials

  def get_source_files(jobs, step) do
    parent_ids = ExBackend.Map.get_by_key_or_atom(step, :parent_ids, [])

    input_filter =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, [])
      |> Enum.filter(fn param ->
        ExBackend.Map.get_by_key_or_atom(param, :id) == "input_filter"
      end)
      |> Enum.map(fn param -> ExBackend.Map.get_by_key_or_atom(param, :value) end)

    paths =
      jobs
      |> Enum.filter(fn job -> job.step_id in parent_ids end)
      |> get_jobs_destination_paths

    case input_filter do
      [%{ends_with: ends_with}] ->
        paths
        |> Enum.filter(fn path -> String.ends_with?(path, ends_with) end)

      [%{"ends_with" => ends_with}] ->
        paths
        |> Enum.filter(fn path -> String.ends_with?(path, ends_with) end)

      _ ->
        paths
    end
  end

  defp get_jobs_destination_paths(jobs) do
    jobs
    |> Enum.map(fn job ->
      get_job_destination_paths(job)
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(fn path -> !is_nil(path) end)
  end

  defp get_job_destination_paths(job) do
    destination_path =
      job.parameters
      |> Enum.filter(fn param ->
        ExBackend.Map.get_by_key_or_atom(param, :id) == "destination_path"
      end)
      |> Enum.map(fn param -> ExBackend.Map.get_by_key_or_atom(param, :value) end)

    destination_paths =
      job.parameters
      |> Enum.filter(fn param ->
        ExBackend.Map.get_by_key_or_atom(param, :id) == "destination_paths"
      end)
      |> Enum.map(fn param -> ExBackend.Map.get_by_key_or_atom(param, :value) end)

    add_items([], destination_path)
    |> add_items(destination_paths)
  end

  defp add_items(list, items) when is_list(items) do
    list ++ items
  end

  defp add_items(list, items) do
    list ++ [items]
  end

  def add_required_paths(path, requirements \\ %{})

  def add_required_paths(paths, requirements) when is_list(paths) do
    Map.update(requirements, :paths, paths, fn cur_paths ->
      Enum.concat(cur_paths, paths)
      |> Enum.uniq()
    end)
  end

  def add_required_paths(path, requirements) do
    paths =
      Map.get(requirements, :paths, [])
      |> List.insert_at(-1, path)

    add_required_paths(paths, requirements)
  end

  def parse_parameters(parameters, workflow, result \\ [])
  def parse_parameters([], _workflow, result), do: result

  def parse_parameters([parameter | parameters], workflow, result) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    value =
      ExBackend.Map.get_by_key_or_atom(parameter, :value)
      |> String.replace("#workflow_id", "<%= workflow_id %>")
      |> String.replace("#work_dir", "<%= work_dir %>")
      |> EEx.eval_string(
        workflow_id: workflow.id,
        work_dir: work_dir
      )

    parameter =
      parameter
      |> Map.delete("value")
      |> Map.delete(:value)
      |> Map.put(:value, value)

    result = List.insert_at(result, -1, parameter)
    parse_parameters(parameters, workflow, result)
  end

  def get_parameter([], _key), do: nil
  def get_parameter([parameter | parameters], key) do
    if ExBackend.Map.get_by_key_or_atom(parameter, :id) == key do
      value =
        ExBackend.Map.get_by_key_or_atom(parameter, :value,
          ExBackend.Map.get_by_key_or_atom(parameter, :default)
        )

      case ExBackend.Map.get_by_key_or_atom(parameter, :type) do
        "credential" ->
          case Credentials.get_credential_by_key(value) do
            nil -> nil
            credential -> credential.value
          end
        _ -> value
      end
    else
      get_parameter(parameters, key)
    end
  end

  def get_workflow_step(workflow, job) do
    get_step(
      ExBackend.Map.get_by_key_or_atom(workflow.flow, :steps),
      ExBackend.Map.get_by_key_or_atom(job, :step_id)
    )
  end

  defp get_step(_, nil), do: nil
  defp get_step([], _step_id), do: nil
  defp get_step([step | steps], step_id) do
    if ExBackend.Map.get_by_key_or_atom(step, :id) == step_id do
      step
    else
      get_step(steps, step_id)
    end
  end
end
