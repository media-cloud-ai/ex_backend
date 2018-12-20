defmodule ExBackend.Workflow.Step.Requirements do
  def get_source_files(jobs, step) do
    parent_ids = ExBackend.Map.get_by_key_or_atom(step, :parent_ids, [])

    input_filter =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, [])
      |> Enum.filter(fn param -> ExBackend.Map.get_by_key_or_atom(param, :id) == "input_filter" end)
      |> Enum.map(fn param -> ExBackend.Map.get_by_key_or_atom(param, :value) end)

    paths =
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

        new_destination_path =
          ExBackend.Map.get_by_key_or_atom(job.params, :list, [])
          |> Enum.filter(fn param -> ExBackend.Map.get_by_key_or_atom(param, :id) == "destination_path" end)
          |> Enum.map(fn param -> ExBackend.Map.get_by_key_or_atom(param, :value) end)

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

        total =
          if is_list(destination_paths) do
            total ++ destination_paths
          else
            total ++ [destination_paths]
          end

        if is_list(new_destination_path) do
          total ++ new_destination_path
        else
          total ++ [new_destination_path]
        end
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.filter(fn path -> !is_nil(path) end)

    case input_filter do
      [%{ends_with: ends_with}] ->
        paths
        |> Enum.filter(fn path -> String.ends_with?(path, ends_with) end)
      [%{"ends_with" => ends_with}] ->
        paths
        |> Enum.filter(fn path -> String.ends_with?(path, ends_with) end)
      _ -> paths
    end
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
      |> EEx.eval_string([
        workflow_id: workflow.id,
        work_dir: work_dir
      ])

    parameter =
      parameter
      |> Map.delete("value")
      |> Map.delete(:value)
      |> Map.put(:value, value)

    result = List.insert_at(result, -1, parameter)
    parse_parameters(parameters, workflow, result)
  end
end
