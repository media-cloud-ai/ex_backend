defmodule ExBackend.Workflow.Step.SpeechToText do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  require Logger

  @action_name "speech_to_text"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    case ExBackend.Map.get_by_key_or_atom(step, :inputs) do
      nil ->
        case  Requirements.get_source_files(workflow.jobs, step) do
          nil ->
            Jobs.create_skipped_job(workflow, step_id, @action_name)

          [] ->
            Jobs.create_skipped_job(workflow, step_id, @action_name)

          paths ->
            paths
            |> Enum.map(fn path -> start_speech_to_text(path, workflow, step) end)

            {:ok, "started"}
        end

      inputs ->
        inputs
        |> Enum.map(fn input ->
          start_speech_to_text(ExBackend.Map.get_by_key_or_atom(input, :path), workflow, step)
        end)

        {:ok, "started"}
    end
  end

  defp start_speech_to_text(path, workflow, step) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    dst_path =
      work_dir <>
        "/" <> Integer.to_string(workflow.id) <> "/" <> (path |> Path.basename()) <> ".vtt"

    requirements = Requirements.new_required_paths(path)

    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, []) ++
        [
          %{
            "id" => "source_path",
            "type" => "string",
            "value" => path
          },
          %{
            "id" => "destination_path",
            "type" => "string",
            "value" => dst_path
          },
          %{
            "id" => "requirements",
            "type" => "requirements",
            "value" => requirements
          }
        ]

    job_params = %{
      name: @action_name,
      step_id: ExBackend.Map.get_by_key_or_atom(step, :id),
      workflow_id: workflow.id,
      parameters: parameters
    }

    {:ok, job} = Jobs.create_job(job_params)

    message = Jobs.get_message(job)

    case CommonEmitter.publish_json("job_speech_to_text", message) do
      :ok -> {:ok, "started"}
      _ -> {:error, "unable to publish message"}
    end
  end
end
