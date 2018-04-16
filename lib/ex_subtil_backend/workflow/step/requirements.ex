defmodule ExSubtilBackend.Workflow.Step.Requirements do
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
end
