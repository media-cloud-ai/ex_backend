defmodule ExSubtilBackend.Workflow.Step.Requirements do

  def get_required_paths(requirements \\ %{}, _path)
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


  def get_required_first_dash_quality_path(requirements \\ %{}, path) do
    if !String.match?(path, ~r/.*\-[a-zA-Z0-9]*\..*/) do
      raise ArgumentError.exception("invalid dash media file: " <> path)
    end

    if !String.ends_with?(path, "-standard1.mp4") do
      required_path = String.replace(path, ~r/\-[a-zA-Z0-9]*\..*/, "-standard1.mp4")

      get_required_paths(requirements, required_path)
    else
      requirements
    end
  end

end
