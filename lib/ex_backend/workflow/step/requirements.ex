defmodule ExBackend.Workflow.Step.Requirements do
  def get_source_files(jobs, step) do
    parent_ids = ExBackend.Map.get_by_key_or_atom(step, :parent_ids, [])

    jobs
    |> Enum.filter(fn job -> job.step_id in parent_ids end)
    |> Enum.map(fn job ->
      output_paths =
        ExBackend.Map.get_by_key_or_atom(job.params, :outputs, [])
        |> Enum.reduce([], fn output, acc ->
          case ExBackend.Map.get_by_key_or_atom(output, :path) do
            nil -> acc
            path -> acc ++ [path]
          end
        end)

      destination_path =
        ExBackend.Map.get_by_key_or_atom(job.params, :destination, %{})
        |> ExBackend.Map.get_by_key_or_atom(:path)

      destination_paths =
        ExBackend.Map.get_by_key_or_atom(job.params, :destination, %{})
        |> ExBackend.Map.get_by_key_or_atom(:paths, [])

      total =
        if is_list(output_paths) do
          output_paths
        else
          [output_paths]
        end

      total =
        if is_list(destination_path) do
          total ++ destination_path
        else
          total ++ [destination_path]
        end

      if is_list(destination_paths) do
        total ++ destination_paths
      else
        total ++ [destination_paths]
      end
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(fn path -> !is_nil(path) end)
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
    value =
      ExBackend.Map.get_by_key_or_atom(parameter, :value)
      |> String.replace("#workflow_id", "<%= workflow_id %>")
      |> EEx.eval_string(workflow_id: workflow.id)

    parameter = Map.replace(parameter, "value", value)
    parameter = Map.replace(parameter, :value, value)

    result = List.insert_at(result, -1, parameter)
    parse_parameters(parameters, workflow, result)
  end
end
