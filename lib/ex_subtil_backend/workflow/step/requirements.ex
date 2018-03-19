defmodule ExSubtilBackend.Workflow.Step.Requirements do

  def get_required_paths(requirements \\ %{}, path)
  def get_required_paths(requirements, paths) when is_list(paths) do
    Map.update(requirements, :paths, paths, fn(cur_paths) ->
      Enum.concat(cur_paths, paths)
      |> Enum.uniq
    end)
  end
  def get_required_paths(requirements, path) do
    paths =
        Map.get(requirements, :paths, [])
        |> List.insert_at(-1, path)
    get_required_paths(requirements, paths)
  end
end
