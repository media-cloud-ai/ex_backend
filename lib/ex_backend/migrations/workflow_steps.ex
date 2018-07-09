defmodule ExBackend.Migration.WorkflowSteps do
  use Ecto.Migration

  alias ExBackend.Repo

  def change do
    Repo.all(ExBackend.Workflows.Workflow)
    |> Enum.map(fn workflow ->
      steps =
        workflow
        |> Map.get(:flow)
        |> Map.get("steps")
        |> process_steps(0, [])

      flow =
        Map.get(workflow, :flow)
        |> Map.put("steps", steps)

      reference = Map.get(workflow, :reference)

      ExBackend.Workflows.Workflow.changeset(workflow, %{
        "reference" => reference,
        "flow" => flow
      })
      |> Repo.update([{:force, true}])
    end)
  end

  def process_steps([], _index, result), do: result

  def process_steps([step | steps], index, result) do
    result = List.insert_at(result, -1, process_step(step, index, result))

    process_steps(steps, index + 1, result)
  end

  def process_step(step, index, processed_steps) do
    if Map.has_key?(step, "name") do
      IO.puts("Skip step migration: #{step["name"]}")
      step
    else
      step_name = Map.get(step, "id")

      step
      |> Map.put("name", step_name)
      |> Map.put("id", index)
      |> Map.put("required", [])
      |> Map.put("parent_ids", get_parent_ids(step_name, processed_steps))
    end
  end

  def get_parent_ids(step_name, processed_steps) do
    parent_names =
      case step_name do
        "download_ftp" -> []
        "download_http" -> ["download_ftp"]
        "audio_extraction" -> ["download_ftp"]
        "audio_decode" -> ["audio_extraction"]
        "acs_prepare_audio" -> ["audio_decode"]
        "acs_synchronize" -> ["acs_prepare_audio"]
        "ttml_to_mp4" -> ["download_http", "acs_synchronize"]
        "set_language" -> ["ttml_to_mp4"]
        "generate_dash" -> ["set_language"]
        "upload_ftp" -> ["generate_dash"]
        "clean_workspace" -> ["upload_ftp"]
        _ -> []
      end

    processed_steps
    |> Enum.filter(fn step ->
      Enum.any?(parent_names, fn name -> Map.get(step, "name") == name end)
    end)
    |> Enum.map(fn step -> Map.get(step, "id") end)
  end
end
