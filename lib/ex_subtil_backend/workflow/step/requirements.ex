defmodule ExSubtilBackend.Workflow.Step.Requirements do

  def get_path_exists(requirements \\ %{}, _path)
  def get_path_exists(requirements, paths) when is_list(paths) do
    Map.update(requirements, :paths, paths, fn(cur_paths) ->
      Enum.concat(cur_paths, paths)
      |> Enum.uniq
    end)
  end
  def get_path_exists(requirements, path) do
    paths =
        Map.get(requirements, :paths, [])
        |> List.insert_at(-1, path)
    get_path_exists(requirements, paths)
  end


  def get_first_dash_quality_path_exists(requirements \\ %{}, path) do
    if !String.match?(path, ~r/.*\-[a-zA-Z0-9]*\..*/) do
      raise ArgumentError.exception("invalid dash media file: " <> path)
    end

    if !String.ends_with?(path, "-standard1.mp4") do
      required_path = String.replace(path, ~r/\-[a-zA-Z0-9]*\..*/, "-standard1.mp4")

      get_path_exists(requirements, required_path)
    else
      requirements
    end
  end

end
