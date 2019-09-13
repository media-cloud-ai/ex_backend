defmodule ExBackend.Workflow.Step.AspProcess do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  require Logger

  @action_name "asp_process"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    case Requirements.get_source_files(workflow.jobs, step) do
      [path1, path2] ->
        if String.ends_with?(path1, ".mp4") do
          start_processing_synchro(path1, path2, workflow, step, step_id)
        else
          start_processing_synchro(path2, path1, workflow, step, step_id)
        end

      _ ->
        Jobs.create_skipped_job(workflow, step_id, @action_name)
    end
  end

  defp start_processing_synchro(video_path, subtitle_path, workflow, step, step_id) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    asp_app = System.get_env("ASP_APP") || Application.get_env(:ex_backend, :asp_app)

    filename =
      Path.basename(subtitle_path)
      |> String.replace(".ttml", "_positioned.ttml")

    dst_path = work_dir <> "/" <> Integer.to_string(workflow.id) <> "/" <> filename

    requirements = Requirements.new_required_paths([video_path, subtitle_path])

    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters) ++
        [
          %{
            "id" => "requirements",
            "type" => "requirements",
            "value" => requirements
          },
          %{
            "id" => "command_template",
            "type" => "string",
            "value" => asp_app <> " {video_path} {subtitle_path} {destination_path}"
          },
          %{
            "id" => "video_path",
            "type" => "string",
            "value" => video_path
          },
          %{
            "id" => "subtitle_path",
            "type" => "string",
            "value" => subtitle_path
          },
          %{
            "id" => "destination_path",
            "type" => "string",
            "value" => dst_path
          }
        ]

    job_params = %{
      name: @action_name,
      step_id: step_id,
      workflow_id: workflow.id,
      parameters: parameters
    }

    {:ok, job} = Jobs.create_job(job_params)

    message = Jobs.get_message(job)

    case CommonEmitter.publish_json("job_asp", message) do
      :ok -> {:ok, "started"}
      _ -> {:error, "unable to publish message"}
    end
  end
end
